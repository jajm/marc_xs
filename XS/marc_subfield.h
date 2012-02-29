#ifndef marc_subfield_h_included
#define marc_subfield_h_included

#include <stdint.h>

typedef struct marc_subfield_s marc_subfield_t;

marc_subfield_t *
marc_subfield_new(
	char code,
	char *val
);

void
marc_subfield_set(
	marc_subfield_t *subfield,
	char code,
	char *val
);

int8_t
marc_subfield_set_code(
	marc_subfield_t *subfield,
	char code
);

int8_t
marc_subfield_set_val(
	marc_subfield_t *subfield,
	char *val
);

char
marc_subfield_get_code(
	marc_subfield_t *subfield
);

char *
marc_subfield_get_val(
	marc_subfield_t *subfield
);

void
marc_subfield_free(
	marc_subfield_t *subfield
);

#endif /* Not marc_subfield_h_included */
