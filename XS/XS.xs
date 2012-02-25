#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include "marc_subfield.h"

typedef marc_subfield_t * MARC_XS_Subfield;

MODULE = MARC::XS		PACKAGE = MARC::XS

void
hell()
	CODE:
		printf("Hell Worl\n");


MODULE = MARC::XS		PACKAGE = MARC::XS::Subfield

MARC_XS_Subfield
new(package, code, val=NULL)
	SV *package
	char code
	char *val
	CODE:
		RETVAL = marc_subfield_new(code, val);
	OUTPUT:
		RETVAL

SV *
code(subfield, code=0)
	MARC_XS_Subfield subfield
	char code
	CODE:
		if(code != 0) {
			marc_subfield_set_code(subfield, code);
		}
		code = marc_subfield_get_code(subfield);
		RETVAL = (code) ? newSVpv(&code, 1) : &PL_sv_undef;
	OUTPUT:
		RETVAL

SV *
val(subfield, val=NULL)
	MARC_XS_Subfield subfield
	char * val
	CODE:
		if(val != NULL) {
			marc_subfield_set_val(subfield, val);
		}
		val = marc_subfield_get_val(subfield);
		RETVAL = (val) ? newSVpv(val, strlen(val)) : &PL_sv_undef;
	OUTPUT:
		RETVAL

void
DESTROY(subfield)
	MARC_XS_Subfield subfield
	CODE:
		marc_subfield_free(subfield);

