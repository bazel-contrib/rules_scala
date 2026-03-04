package scalaparser

import (
	"fmt"
	"reflect"
	"sync"
	"testing"
)

func TestParseExtractsScalaMetadata(t *testing.T) {
	source := []byte(`
package com.example

import java.util.List
import com.acme.tools._
import scala.util.{Try => T, Success}

class PublicClass
trait PublicTrait
object PublicObj
private class PrivateImpl
private object PrivateObj
`)

	metadata, err := Parse(source)
	if err != nil {
		t.Fatalf("Parse() error: %v", err)
	}

	if metadata.Package != "com.example" {
		t.Fatalf("Package = %q, want %q", metadata.Package, "com.example")
	}

	wantClasses := []string{
		"java.util.List",
		"scala.util.Success",
		"scala.util.Try",
	}
	if !reflect.DeepEqual(metadata.ImportedClasses, wantClasses) {
		t.Fatalf("ImportedClasses = %v, want %v", metadata.ImportedClasses, wantClasses)
	}

	wantPackages := []string{"com.acme.tools"}
	if !reflect.DeepEqual(metadata.ImportedPackages, wantPackages) {
		t.Fatalf("ImportedPackages = %v, want %v", metadata.ImportedPackages, wantPackages)
	}

	wantExported := []string{
		"com.example.PublicClass",
		"com.example.PublicObj",
		"com.example.PublicTrait",
	}
	if !reflect.DeepEqual(metadata.ExportedSymbols, wantExported) {
		t.Fatalf("ExportedSymbols = %v, want %v", metadata.ExportedSymbols, wantExported)
	}
}

func TestParseConcatenatesNestedPackageClauses(t *testing.T) {
	source := []byte(`
package com.example
package api

import foo.bar.Baz

object Endpoints
`)

	metadata, err := Parse(source)
	if err != nil {
		t.Fatalf("Parse() error: %v", err)
	}

	if metadata.Package != "com.example.api" {
		t.Fatalf("Package = %q, want %q", metadata.Package, "com.example.api")
	}

	wantClasses := []string{"foo.bar.Baz"}
	if !reflect.DeepEqual(metadata.ImportedClasses, wantClasses) {
		t.Fatalf("ImportedClasses = %v, want %v", metadata.ImportedClasses, wantClasses)
	}

	wantExported := []string{"com.example.api.Endpoints"}
	if !reflect.DeepEqual(metadata.ExportedSymbols, wantExported) {
		t.Fatalf("ExportedSymbols = %v, want %v", metadata.ExportedSymbols, wantExported)
	}
}

func TestParseConcurrent(t *testing.T) {
	source := []byte(`
package com.example
import java.util.List
class App
`)

	const workers = 12
	const rounds = 40

	var wg sync.WaitGroup
	errCh := make(chan error, workers*rounds)

	for i := 0; i < workers; i++ {
		wg.Add(1)
		go func() {
			defer wg.Done()
			for j := 0; j < rounds; j++ {
				metadata, err := Parse(source)
				if err != nil {
					errCh <- err
					return
				}
				if metadata.Package != "com.example" {
					errCh <- fmt.Errorf("package = %q, want com.example", metadata.Package)
					return
				}
				if len(metadata.ExportedSymbols) != 1 || metadata.ExportedSymbols[0] != "com.example.App" {
					errCh <- fmt.Errorf("exported = %v, want [com.example.App]", metadata.ExportedSymbols)
					return
				}
			}
		}()
	}

	wg.Wait()
	close(errCh)
	for err := range errCh {
		t.Fatal(err)
	}
}
