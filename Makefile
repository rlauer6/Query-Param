#-*- mode: makefile; -*-

MODULE = Query::Param

PERL_MODULES = \
    lib/Query/Param.pm

VERSION := $(shell cat VERSION)

TARBALL = Query-Param-$(VERSION).tar.gz

all: $(TARBALL)

lib/Query/Param.pm: lib/Query/Param.pm.in
	sed -e 's/[@]PACKAGE_VERSION[@]/$(VERSION)/' $< > $@

$(TARBALL): buildspec.yml $(PERL_MODULES) requires test-requires README.md
	make-cpan-dist.pl -b $<

README.md: $(PERL_MODULES)
	pod2markdown $< > $@

include version.mk

clean:
	rm -f *.tar.gz
