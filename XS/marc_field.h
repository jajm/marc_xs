#ifndef marc_field_h_included
#define marc_field_h_included

#include <stdint.h>
#include "marc_subfield.h"

typedef struct marc_field_s marc_field_t;

marc_field_t *
marc_field_new(
	uint16_t tag,
	char ind1,
	char ind2
);

int8_t
marc_field_set_tag(
	marc_field_t *f,
	uint16_t tag
);

uint16_t
marc_field_get_tag(
	marc_field_t *f
);

int8_t
marc_field_set_indicator(
	marc_field_t *f,
	uint8_t pos,
	char value
);

char
marc_field_get_indicator(
	marc_field_t *f,
	uint8_t pos
);

int8_t
marc_field_set_value(
	marc_field_t *f,
	char *value
);

char *
marc_field_get_value(
	marc_field_t *f
);

marc_subfield_t *
marc_field_add_subfield(
	marc_field_t *f,
	char code,
	char *value
);

marc_subfield_t *
marc_field_pop_subfield(
	marc_field_t *f,
	uint32_t pos
);

void marc_field_free(
	marc_field_t *f
);

/*
 * Subfields iterator
 */

typedef struct marc_field_subfields_iterator_s marc_field_subfields_iterator_t;

marc_field_subfields_iterator_t *
marc_field_subfields_iterator_new(
	marc_field_t *f
);

int8_t
marc_field_subfields_iterator_next(
	marc_field_subfields_iterator_t *it
);

marc_subfield_t *
marc_field_subfields_iterator_get(
	marc_field_subfields_iterator_t *it
);

void
marc_field_subfields_iterator_free(
	marc_field_subfields_iterator_t *it
);

#endif /* Not marc_field_h_included */
