#include <stdint.h>
#include <stdlib.h>
#include "marc_xs_subfield.h"
#include "marc_field.h"
#include "marc_xs_field.h"

struct marc_xs_field_s {
	marc_field_t *f;
	uint32_t refcount;
	marc_xs_field_t *next;
};

#define MARC_XS_FIELD_MAP_SIZE 1024
marc_xs_field_t * marc_xs_fields_map[MARC_XS_FIELD_MAP_SIZE] = {0};

inline uint32_t marc_xs_field_hash(marc_field_t *f)
{
	return (uint32_t)((intptr_t)f % MARC_XS_FIELD_MAP_SIZE);
}

marc_xs_field_t * marc_xs_field_new(marc_field_t *f)
{
	marc_xs_field_t *xs_f = NULL, *node, *prev = NULL;
	uint32_t hash;

	if(f == NULL) return NULL;

	hash = marc_xs_field_hash(f);
	node = marc_xs_fields_map[hash];
	while(node != NULL) {
		if(node->f == f) {
			xs_f = node;
			break;
		}
		prev = node;
		node = node->next;
	}

	if(xs_f == NULL) {
		xs_f = malloc(sizeof(marc_xs_field_t));
		if(xs_f == NULL) return NULL;
		xs_f->f = f;
		xs_f->refcount = 1;
		xs_f->next = NULL;
		if(prev) {
			prev->next = xs_f;
		} else {
			marc_xs_fields_map[hash] = xs_f;
		}
	} else {
		xs_f->refcount ++;
	}

	return xs_f;
}

marc_field_t * marc_xs_field_get(marc_xs_field_t *xs_f)
{
	if(xs_f == NULL) {
		return NULL;
	}

	return xs_f->f;
}

int8_t marc_xs_field_dec(marc_field_t *f)
{
	uint32_t hash;
	marc_xs_field_t *node;

	if(f == NULL) {
		return -1;
	}

	hash = marc_xs_field_hash(f);
	node = marc_xs_fields_map[hash];
	while(node != NULL && node->f != f) {
		node = node->next;
	}
	if(node) {
		marc_xs_field_free(node);
	}

	return 0;
}

void marc_xs_field_free(marc_xs_field_t *xs_f)
{
	marc_xs_field_t *node, *prev = NULL;
	marc_subfield_t *s;
	uint32_t hash;

	if(xs_f) {
		xs_f->refcount--;
		if(xs_f->refcount == 0) {
			hash = marc_xs_field_hash(xs_f->f);
			node = marc_xs_fields_map[hash];
			while(node != NULL) {
				if(node == xs_f) break;
				prev = node;
				node = node->next;
			}
			if(prev) {
				prev->next = node->next;
			} else {
				marc_xs_fields_map[hash] = node->next;
			}
			while( (s = marc_field_pop_subfield(node->f, 0)) ) {
				marc_xs_subfield_dec(s);
			}
			marc_field_free(node->f);
			free(node);
		}
	}
}
