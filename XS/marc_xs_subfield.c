#include <stdint.h>
#include <stdlib.h>
#include "marc_subfield.h"
#include "marc_xs_subfield.h"

struct marc_xs_subfield_s {
	marc_subfield_t *s;
	uint32_t refcount;
	marc_xs_subfield_t *next;
};

#define MARC_XS_SUBFIELD_MAP_SIZE 1024
marc_xs_subfield_t * marc_xs_subfields_map[MARC_XS_SUBFIELD_MAP_SIZE] = {0};

inline uint32_t marc_xs_subfield_hash(marc_subfield_t *s)
{
	return (uint32_t)((intptr_t)s % MARC_XS_SUBFIELD_MAP_SIZE);
}

marc_xs_subfield_t * marc_xs_subfield_new(marc_subfield_t *s)
{
	marc_xs_subfield_t *xs_s = NULL, *node, *prev = NULL;
	uint32_t hash;

	if(s == NULL) return NULL;

	hash = marc_xs_subfield_hash(s);
	node = marc_xs_subfields_map[hash];
	while(node != NULL) {
		if(node->s == s) {
			xs_s = node;
			break;
		}
		prev = node;
		node = node->next;
	}
	if(xs_s == NULL) {
		xs_s = malloc(sizeof(marc_xs_subfield_t));
		if(xs_s == NULL) return NULL;
		xs_s->s = s;
		xs_s->refcount = 1;
		xs_s->next = NULL;
		if(prev) {
			prev->next = xs_s;
		} else {
			marc_xs_subfields_map[hash] = xs_s;
		}
	} else {
		xs_s->refcount ++;
	}

	return xs_s;
}

marc_subfield_t * marc_xs_subfield_get(marc_xs_subfield_t *xs_s)
{
	if(xs_s == NULL) {
		return NULL;
	}

	return xs_s->s;
}

int8_t marc_xs_subfield_dec(marc_subfield_t *s)
{
	uint32_t hash;
	marc_xs_subfield_t *node;

	if(s == NULL) {
		return -1;
	}

	hash = marc_xs_subfield_hash(s);
	node = marc_xs_subfields_map[hash];
	while(node != NULL && node->s != s) {
		node = node->next;
	}
	if(node) {
		marc_xs_subfield_free(node);
	}

	return 0;
}

void marc_xs_subfield_free(marc_xs_subfield_t *xs_s)
{
	marc_xs_subfield_t *node, *prev = NULL;
	uint32_t hash;
	if(xs_s) {
		xs_s->refcount--;
		if(xs_s->refcount == 0) {
			hash = marc_xs_subfield_hash(xs_s->s);
			node = marc_xs_subfields_map[hash];
			while(node != NULL) {
				if(node == xs_s) break;
				prev = node;
				node = node->next;
			}
			if(prev) {
				prev->next = node->next;
			} else {
				marc_xs_subfields_map[hash] = node->next;
			}
			marc_subfield_free(node->s);
			free(node);
		}
	}
}
