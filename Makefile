#-*- mode: makefile; -*-

MODULE = Query::Param

PERL_MODULES = \
    lib/Query/Param.pm

VERSION := $(shell perl -I lib -M$(MODULE) -e 'print $$Query::Param::VERSION;')

TARBALL = Query-Param-$(VERSION).tar.gz

$(TARBALL): buildspec.yml $(PERL_MODULES) requires test-requires README.md
	make-cpan-dist.pl -b $<

README.md: $(PERL_MODULES)
	pod2markdown $< > $@

clean:
	rm -f *.tar.gz
