#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include "marc_subfield.h"
#include "marc_xs_subfield.h"

struct marc_xs_subfield_s {
	marc_subfield_t *s;
	uint32_t refcount;
	marc_xs_subfield_t *next;
	marc_xs_subfield_t *prev;
};

#define MARC_XS_SUBFIELD_MAP_SIZE 10240
marc_xs_subfield_t * marc_xs_subfields_map[MARC_XS_SUBFIELD_MAP_SIZE] = {0};

inline uint32_t marc_xs_subfield_hash(marc_subfield_t *s)
{
	return (uint32_t)( ((intptr_t)s / 16) % MARC_XS_SUBFIELD_MAP_SIZE);
}

marc_xs_subfield_t * marc_xs_subfield_new(marc_subfield_t *s)
{
	marc_xs_subfield_t *xs_s;
	uint32_t hash;

	if(s == NULL)
		return NULL;

	xs_s = malloc(sizeof(marc_xs_subfield_t));
	if(xs_s == NULL)
		return NULL;

	hash = marc_xs_subfield_hash(s);
	xs_s->s = s;
	xs_s->refcount = 1;
	xs_s->next = marc_xs_subfields_map[hash];
	if(xs_s->next != NULL) {
		xs_s->next->prev = xs_s;
	}
	xs_s->prev = NULL;
	marc_xs_subfields_map[hash] = xs_s;

	return xs_s;
}

marc_xs_subfield_t * marc_xs_subfield_inc(marc_subfield_t *s)
{
	marc_xs_subfield_t *xs_s = NULL, *node;
	uint32_t hash;

	if(s == NULL)
		return NULL;

	hash = marc_xs_subfield_hash(s);
	node = marc_xs_subfields_map[hash];
	while(node != NULL) {
		if(node->s == s) {
			xs_s = node;
			break;
		}
		node = node->next;
	}
	if(xs_s != NULL) {
		xs_s->refcount ++;
	} else {
		xs_s = marc_xs_subfield_new(s);
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

	if(s == NULL)
		return -1;

	hash = marc_xs_subfield_hash(s);
	node = marc_xs_subfields_map[hash];
	while(node != NULL && node->s != s) {
		node = node->next;
	}
	marc_xs_subfield_free(node);

	return 0;
}

void marc_xs_subfield_free(marc_xs_subfield_t *xs_s)
{
	uint32_t hash;
	if(xs_s) {
		xs_s->refcount--;
		if(xs_s->refcount == 0) {
			if(xs_s->prev != NULL) {
				xs_s->prev->next = xs_s->next;
			} else {
				hash = marc_xs_subfield_hash(xs_s->s);
				marc_xs_subfields_map[hash] = xs_s->next;
			}
			if(xs_s->next != NULL) {
				xs_s->next->prev = xs_s->prev;
			}
			marc_subfield_free(xs_s->s);
			free(xs_s);
		}
	}
}
