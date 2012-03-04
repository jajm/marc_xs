#ifndef marc_xs_subfield_included
#define marc_xs_subfield_included

#include "marc_subfield.h"

typedef struct marc_xs_subfield_s marc_xs_subfield_t;

marc_xs_subfield_t *
marc_xs_subfield_new(
	marc_subfield_t *s
);

marc_xs_subfield_t *
marc_xs_subfield_inc(
	marc_subfield_t *s
);

int8_t
marc_xs_subfield_dec(
	marc_subfield_t *s
);

marc_subfield_t *
marc_xs_subfield_get(
	marc_xs_subfield_t *xs_s
);

void
marc_xs_subfield_free(
	marc_xs_subfield_t *xs_s
);


#endif /* Not marc_xs_subfield_included */
