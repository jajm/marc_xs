#ifndef marc_xs_field_included
#define marc_xs_field_included

#include "marc_field.h"

typedef struct marc_xs_field_s marc_xs_field_t;

marc_xs_field_t *
marc_xs_field_new(
	marc_field_t *s
);

marc_xs_field_t *
marc_xs_field_inc(
	marc_field_t *s
);

int8_t
marc_xs_field_dec(
	marc_field_t *s
);

marc_field_t *
marc_xs_field_get(
	marc_xs_field_t *xs_s
);

void
marc_xs_field_free(
	marc_xs_field_t *xs_s
);

#endif /* Not marc_xs_field_included */
