package scalaparser

import (
	"fmt"
	"sort"
	"strings"
	"unicode"
	"unicode/utf8"

	"github.com/odvcencio/gotreesitter"
	"github.com/odvcencio/gotreesitter/grammars"
)

var (
	scalaLang       = grammars.DetectLanguage("Test.scala").Language()
	scalaParserPool = gotreesitter.NewParserPool(scalaLang)
)

type FileMetadata struct {
	Package          string
	ImportedClasses  []string
	ImportedPackages []string
	ExportedSymbols  []string
}

type Parser struct {
	parserPool *gotreesitter.ParserPool
	lang       *gotreesitter.Language
}

func New() *Parser {
	return &Parser{
		parserPool: scalaParserPool,
		lang:       scalaLang,
	}
}

func Parse(content []byte) (*FileMetadata, error) {
	return New().Parse(content)
}

func (p *Parser) Parse(content []byte) (*FileMetadata, error) {
	tree, err := p.parserPool.Parse(content)
	if err != nil {
		return nil, fmt.Errorf("parse scala: %w", err)
	}
	if tree == nil || tree.RootNode() == nil {
		return nil, fmt.Errorf("parse scala: nil tree")
	}
	defer tree.Release()

	root := tree.RootNode()
	classImports := map[string]struct{}{}
	pkgImports := map[string]struct{}{}
	exported := map[string]struct{}{}
	parsedPackage := ""

	for i := 0; i < root.NamedChildCount(); i++ {
		child := root.NamedChild(i)
		switch child.Type(p.lang) {
		case "package_clause":
			pkgPart := parsePackageClause(child, p.lang, content)
			if pkgPart == "" {
				continue
			}
			if parsedPackage == "" {
				parsedPackage = pkgPart
			} else {
				parsedPackage += "." + pkgPart
			}
		case "import_declaration":
			extractImportDeclaration(child, p.lang, content, classImports, pkgImports)
		case "class_definition", "trait_definition":
			if name := parseTopLevelTypeName(child, p.lang, content); name != "" &&
				!hasPrivateOrProtectedModifier(child, p.lang, content) {
				exported[name] = struct{}{}
			}
		case "object_definition":
			if name := parseTopLevelTypeName(child, p.lang, content); name != "" &&
				!hasPrivateOrProtectedModifier(child, p.lang, content) {
				exported[name] = struct{}{}
			}
		case "postfix_expression", "infix_expression":
			_, name, privateLike := extractScalaPostfixLikeDecl(child, p.lang, content)
			if name != "" && !privateLike {
				exported[name] = struct{}{}
			}
		}
	}

	exportedFQNs := make([]string, 0, len(exported))
	for symbol := range exported {
		if parsedPackage == "" {
			exportedFQNs = append(exportedFQNs, symbol)
		} else {
			exportedFQNs = append(exportedFQNs, parsedPackage+"."+symbol)
		}
	}
	sort.Strings(exportedFQNs)

	return &FileMetadata{
		Package:          parsedPackage,
		ImportedClasses:  sortedKeys(classImports),
		ImportedPackages: sortedKeys(pkgImports),
		ExportedSymbols:  exportedFQNs,
	}, nil
}

func parsePackageClause(node *gotreesitter.Node, lang *gotreesitter.Language, content []byte) string {
	packageIdentifier := findFirstNamedChild(node, lang, "package_identifier")
	if packageIdentifier == nil {
		return ""
	}
	return normalizeQualified(packageIdentifier.Text(content))
}

func parseTopLevelTypeName(node *gotreesitter.Node, lang *gotreesitter.Language, content []byte) string {
	return findFirstNamedChildText(node, content, lang, "identifier")
}

func extractImportDeclaration(
	node *gotreesitter.Node,
	lang *gotreesitter.Language,
	content []byte,
	classImports map[string]struct{},
	pkgImports map[string]struct{},
) {
	identifiers := make([]string, 0, 4)
	var selectors *gotreesitter.Node
	hasWildcard := false

	for i := 0; i < node.NamedChildCount(); i++ {
		child := node.NamedChild(i)
		switch child.Type(lang) {
		case "identifier":
			identifiers = append(identifiers, child.Text(content))
		case "namespace_wildcard":
			hasWildcard = true
		case "namespace_selectors":
			selectors = child
		}
	}

	if len(identifiers) == 0 {
		return
	}

	prefix := normalizeQualified(strings.Join(identifiers, "."))
	if prefix == "" {
		return
	}

	if hasWildcard {
		pkgImports[prefix] = struct{}{}
		return
	}

	if selectors != nil {
		importedAnyClass := false
		for _, sel := range extractScalaImportSelectors(selectors, lang, content) {
			if sel.original == "" || !isLikelyTypeName(sel.original) {
				continue
			}
			classImports[prefix+"."+sel.original] = struct{}{}
			importedAnyClass = true
		}
		if !importedAnyClass {
			pkgImports[prefix] = struct{}{}
		}
		return
	}

	last := identifiers[len(identifiers)-1]
	if isLikelyTypeName(last) {
		classImports[prefix] = struct{}{}
		return
	}

	if pkg := pathWithoutLastSegment(prefix); pkg != "" {
		pkgImports[pkg] = struct{}{}
	} else {
		pkgImports[prefix] = struct{}{}
	}
}

type scalaImportSelector struct {
	original string
}

func extractScalaImportSelectors(
	selectors *gotreesitter.Node,
	lang *gotreesitter.Language,
	content []byte,
) []scalaImportSelector {
	out := make([]scalaImportSelector, 0, selectors.NamedChildCount())
	for i := 0; i < selectors.NamedChildCount(); i++ {
		child := selectors.NamedChild(i)
		switch child.Type(lang) {
		case "identifier":
			out = append(out, scalaImportSelector{original: child.Text(content)})
		case "arrow_renamed_identifier":
			original := ""
			for j := 0; j < child.NamedChildCount(); j++ {
				id := child.NamedChild(j)
				if id.Type(lang) != "identifier" {
					continue
				}
				if original == "" {
					original = id.Text(content)
				}
			}
			out = append(out, scalaImportSelector{original: original})
		}
	}
	return out
}

func extractScalaPostfixLikeDecl(
	node *gotreesitter.Node,
	lang *gotreesitter.Language,
	content []byte,
) (kind string, name string, isPrivate bool) {
	idents := make([]string, 0, 3)
	for i := 0; i < node.NamedChildCount(); i++ {
		child := node.NamedChild(i)
		if child.Type(lang) == "identifier" {
			idents = append(idents, child.Text(content))
		}
	}
	if len(idents) < 2 {
		return "", "", false
	}
	if len(idents) == 2 {
		switch idents[0] {
		case "object", "trait":
			return idents[0], idents[1], false
		}
	}
	if len(idents) >= 3 && idents[0] == "private" {
		switch idents[1] {
		case "object", "trait":
			return idents[1], idents[2], true
		}
	}
	return "", "", false
}

func hasPrivateOrProtectedModifier(
	node *gotreesitter.Node,
	lang *gotreesitter.Language,
	content []byte,
) bool {
	modifiers := findFirstNamedChild(node, lang, "modifiers")
	if modifiers == nil {
		return false
	}
	text := modifiers.Text(content)
	return strings.Contains(text, "private") || strings.Contains(text, "protected")
}

func findFirstNamedChild(
	node *gotreesitter.Node,
	lang *gotreesitter.Language,
	typ string,
) *gotreesitter.Node {
	for i := 0; i < node.NamedChildCount(); i++ {
		child := node.NamedChild(i)
		if child.Type(lang) == typ {
			return child
		}
	}
	return nil
}

func findFirstNamedChildText(
	node *gotreesitter.Node,
	content []byte,
	lang *gotreesitter.Language,
	typ string,
) string {
	child := findFirstNamedChild(node, lang, typ)
	if child == nil {
		return ""
	}
	return child.Text(content)
}

func isLikelyTypeName(name string) bool {
	name = strings.TrimSpace(name)
	if name == "" {
		return false
	}
	r, _ := utf8.DecodeRuneInString(name)
	return unicode.IsUpper(r)
}

func pathWithoutLastSegment(path string) string {
	lastDot := strings.LastIndex(path, ".")
	if lastDot == -1 {
		return ""
	}
	return path[:lastDot]
}

func normalizeQualified(path string) string {
	return strings.TrimPrefix(strings.TrimSpace(path), "_root_.")
}

func sortedKeys(set map[string]struct{}) []string {
	out := make([]string, 0, len(set))
	for k := range set {
		out = append(out, k)
	}
	sort.Strings(out)
	return out
}
