#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include "marc_subfield.h"
#include "marc_xs_subfield.h"
#include "marc_field.h"
#include "marc_xs_field.h"

typedef marc_xs_subfield_t * MARC_XS_Subfield;
typedef marc_xs_field_t * MARC_XS_Field;

MODULE = MARC::XS		PACKAGE = MARC::XS

MODULE = MARC::XS		PACKAGE = MARC::XS::Subfield

MARC_XS_Subfield
new(package, code, val=NULL)
	SV *package
	char code
	char *val
	INIT:
		marc_subfield_t *s;
		marc_xs_subfield_t *xs_s;
	CODE:
		s = marc_subfield_new(code, val);
		if(s == NULL) {
			croak("Failed to create a new subfield");
		}
		xs_s = marc_xs_subfield_new(s);
		if(xs_s == NULL) {
			croak("Failed to create a new MARC::XS::Subfield");
		}
		RETVAL = xs_s;
	OUTPUT:
		RETVAL

SV *
code(subfield, code=0)
	MARC_XS_Subfield subfield
	char code
	INIT:
		marc_subfield_t *s;
	CODE:
		s = marc_xs_subfield_get(subfield);
		if(s == NULL) {
			croak("Failed to retrieve the subfield");
		}
		if(code != 0) {
			marc_subfield_set_code(s, code);
		}
		code = marc_subfield_get_code(s);
		RETVAL = (code) ? newSVpv(&code, 1) : &PL_sv_undef;
	OUTPUT:
		RETVAL

SV *
val(subfield, val=NULL)
	MARC_XS_Subfield subfield
	char * val
	INIT:
		marc_subfield_t *s;
	CODE:
		s = marc_xs_subfield_get(subfield);
		if(s == NULL) {
			croak("Failed to retrieve the subfield");
		}
		if(val != NULL) {
			marc_subfield_set_val(s, val);
		}
		val = marc_subfield_get_val(s);
		RETVAL = (val) ? newSVpv(val, strlen(val)) : &PL_sv_undef;
	OUTPUT:
		RETVAL

void
DESTROY(subfield)
	MARC_XS_Subfield subfield
	CODE:
		marc_xs_subfield_free(subfield);

MODULE = MARC::XS		PACKAGE = MARC::XS::Field

MARC_XS_Field
new(package, tag, ...)
	SV *package
	unsigned short tag
	INIT:
		marc_field_t *f = NULL;
		marc_xs_field_t *xs_f;
		int i;
		char ind1, ind2;
		char *val;
		marc_subfield_t *s;
	CODE:
		if(tag < 10) {
			f = marc_field_new(tag, 0, 0);
			if(items > 2) {
				val = (char*)SvPV_nolen(ST(2));
				marc_field_set_value(f, val);
			}
		} else {
			if(items >= 4) {
				ind1 = (char)*SvPV_nolen(ST(2));
				ind2 = (char)*SvPV_nolen(ST(3));
				f = marc_field_new(tag, ind1, ind2);
				for(i=4; i<items; i+=2){
					if(i+1 < items) {
						char code = (char)*SvPV_nolen(ST(i));
						char *val = (char *)SvPV_nolen(ST(i+1));
						s = marc_field_add_subfield(f, code, val);
						marc_xs_subfield_new(s);
					}
				}
			}
		}
		xs_f = marc_xs_field_new(f);
		RETVAL = xs_f;
	OUTPUT:
		RETVAL

void
subfields(field)
	MARC_XS_Field field
	INIT:
		marc_field_t *f;
		marc_field_subfields_iterator_t *it;
		marc_subfield_t *s;
		marc_xs_subfield_t *xs_s;
		SV *sv;
	PPCODE:
		f = marc_xs_field_get(field);
		it = marc_field_subfields_iterator_new(f);
		while(marc_field_subfields_iterator_next(it) == 0) {
			s = marc_field_subfields_iterator_get(it);
			xs_s = marc_xs_subfield_new(s);
			sv = newSV(0);
			sv_setref_pv(sv, "MARC::XS::Subfield", (void*)xs_s);
			XPUSHs(sv);
		}
		marc_field_subfields_iterator_free(it);

void DESTROY(field)
	MARC_XS_Field field
	CODE:
		marc_xs_field_free(field);

void
print(field)
	MARC_XS_Field field
	INIT:
		marc_field_t *f;
		marc_subfield_t *s;
		marc_field_subfields_iterator_t *it;
		uint16_t tag;
	CODE:
		f = marc_xs_field_get(field);
		tag = marc_field_get_tag(f);
		printf("Field %03d [%c][%c]:",
			tag,
			marc_field_get_indicator(f, 0),
			marc_field_get_indicator(f, 1));
		if(tag < 10) {
			printf("\t%s\n", marc_field_get_value(f));
		} else {
			printf("\n");
			it = marc_field_subfields_iterator_new(f);
			while(marc_field_subfields_iterator_next(it) == 0) {
				s = marc_field_subfields_iterator_get(it);
				printf("\t%c => %s\n",
					marc_subfield_get_code(s),
					marc_subfield_get_val(s));
			}
		}
		printf("\n");

