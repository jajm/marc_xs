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
		xs_s = marc_xs_subfield_new(s);
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

SV *
tag(field, tag=1000)
	MARC_XS_Field field
	uint16_t tag
	INIT:
		marc_field_t *f;
		char tagstring[4];
	CODE:
		f = marc_xs_field_get(field);
		if(tag < 1000) {
			marc_field_set_tag(f, tag);
		}
		tag = marc_field_get_tag(f);
		sprintf(tagstring, "%03d", tag);
		RETVAL = newSVpv(tagstring, 3);
	OUTPUT:
		RETVAL

int8_t
is_control_field(field)
	MARC_XS_Field field
	INIT:
		marc_field_t *f;
		uint16_t tag;
	CODE:
		f = marc_xs_field_get(field);
		tag = marc_field_get_tag(f);
		if(tag < 10)
			RETVAL = 1;
		else
			RETVAL = 0;
	OUTPUT:
		RETVAL

void
subfield(field, code)
	MARC_XS_Field field
	char code
	INIT:
		marc_field_t *f;
		marc_field_subfields_iterator_t *it;
		marc_subfield_t *s;
		marc_xs_subfield_t *xs_s;
		SV *sv;
		I32 gimme;
	PPCODE:
		gimme = GIMME_V;
		f = marc_xs_field_get(field);
		it = marc_field_subfields_iterator_new(f);
		while(marc_field_subfields_iterator_next(it) == 0) {
			s = marc_field_subfields_iterator_get(it);
			if(marc_subfield_get_code(s) == code) {
				xs_s = marc_xs_subfield_inc(s);
				sv = newSV(0);
				sv_setref_pv(sv, "MARC::XS::Subfield", (void*)xs_s);
				XPUSHs(sv);
				if(gimme == G_SCALAR)
					break;
			}
		}
		marc_field_subfields_iterator_free(it);

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
			xs_s = marc_xs_subfield_inc(s);
			sv = newSV(0);
			sv_setref_pv(sv, "MARC::XS::Subfield", (void*)xs_s);
			XPUSHs(sv);
		}
		marc_field_subfields_iterator_free(it);

char *
data(field, data=NULL)
	MARC_XS_Field field
	char *data
	INIT:
		marc_field_t *f;
	CODE:
		f = marc_xs_field_get(field);
		if(data != NULL) {
			marc_field_set_value(f, data);
		}
		RETVAL = marc_field_get_value(f);
	OUTPUT:
		RETVAL

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

