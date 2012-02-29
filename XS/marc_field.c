#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include "marc_field.h"

typedef struct marc_subfield_list_node_s {
	marc_subfield_t *s;
	struct marc_subfield_list_node_s *next;
} marc_subfield_list_node_t;

typedef struct {
	marc_subfield_list_node_t *first;
	marc_subfield_list_node_t *last;
} marc_subfield_list_t;

marc_subfield_list_node_t * marc_subfield_list_add(
	marc_subfield_list_t *list, marc_subfield_t *s)
{
	marc_subfield_list_node_t *node, *prev = NULL;

	if(list == NULL || s == NULL) {
		return NULL;
	}
	prev = list->last;
	node = malloc(sizeof(marc_subfield_list_node_t));
	if(node == NULL) {
		return NULL;
	}
	node->s = s;
	node->next = NULL;
	if(prev == NULL) {
		list->first = node;
	} else {
		prev->next = node;
	}
	list->last = node;
	return node;
}

int8_t marc_subfield_list_del(marc_subfield_list_t *list,
	const marc_subfield_t *s)
{
	marc_subfield_list_node_t *node, *prev = NULL;
	if(list == NULL || s == NULL) {
		return -1;
	}
	node = list->first;
	while(node != NULL && node->s != s) {
		prev = node;
		node = node->next;
	}
	if(node != NULL) {
		if(prev == NULL) {
			list->first = node->next;
		} else {
			prev->next = node->next;
		}
		if(node == list->last) {
			list->last = prev;
		}
		marc_subfield_free(node->s);
		free(node);
	}
	return 0;
}

int8_t marc_subfield_list_del_by_code(marc_subfield_list_t *list,
	char code)
{
	marc_subfield_list_node_t *node, *prev = NULL;
	if(list == NULL) {
		return -1;
	}
	node = list->first;
	while(node != NULL && code != marc_subfield_get_code(node->s)) {
		prev = node;
		node = node->next;
	}
	if(node != NULL) {
		if(prev == NULL) {
			list->first = node->next;
		} else {
			prev->next = node->next;
		}
		if(node == list->last) {
			list->last = prev;
		}
		marc_subfield_free(node->s);
		free(node);
	}
	return 0;
}

marc_subfield_t * marc_subfield_list_pop(marc_subfield_list_t *list,
	uint32_t pos)
{
	marc_subfield_list_node_t *node, *prev = NULL;
	marc_subfield_t *s = NULL;
	uint32_t i = 0;

	if(list == NULL) {
		return NULL;
	}

	node = list->first;
	while(node != NULL && i < pos) {
		prev = node;
		node = node->next;
		i++;
	}
	if(node) {
		s = node->s;
		if(prev) {
			prev->next = node->next;
		} else {
			list->first = node->next;
		}
		if(node == list->last) {
			list->last = prev;
		}
		free(node);
	}

	return s;
}

void marc_subfield_list_free(marc_subfield_list_t *list)
{
	marc_subfield_list_node_t *node;
	if(list != NULL) {
		node = list->first;
		while(node != NULL) {
			marc_subfield_free(node->s);
			free(node);
			node = node->next;
		}
		free(list);
	}
}

struct marc_field_s {
	uint16_t tag;
	char ind[2];
	union {
		marc_subfield_list_t *subfields;
		char *value;
	} data;
};

marc_field_t * marc_field_new(uint16_t tag, char ind1, char ind2)
{
	marc_field_t *f;

	if(tag > 999) {
		return NULL;
	}
	f = malloc(sizeof(marc_field_t));
	if(f == NULL) {
		return NULL;
	}
	if(tag < 10) {
		f->data.value = NULL;
	} else {
		f->data.subfields = malloc(sizeof(marc_subfield_list_t));
		if(f->data.subfields == NULL) {
			return NULL;
		}
		f->data.subfields->first = NULL;
		f->data.subfields->last = NULL;
	}
	f->tag = tag;
	f->ind[0] = ind1;
	f->ind[1] = ind2;

	return f;
}

int8_t marc_field_set_tag(marc_field_t *f, uint16_t tag)
{
	if(f == NULL || tag > 999) {
		return -1;
	}
	f->tag = tag;
	return 0;
}

uint16_t marc_field_get_tag(marc_field_t *f)
{
	if(f == NULL) {
		return 1000;    // Error
	}
	return f->tag;
}

int8_t marc_field_set_indicator(marc_field_t *f, uint8_t pos, char value)
{
	if(f == NULL || pos > 1)
		return -1;

	f->ind[pos] = value;
	return 0;
}

char marc_field_get_indicator(marc_field_t *f, uint8_t pos)
{
	if(f == NULL || pos > 1)
		return 0;

	return f->ind[pos];
}

int8_t marc_field_set_value(marc_field_t *f, char *value)
{
	size_t len;
	char *_value;
	if(f == NULL) {
		return -1;
	}
	if(f->tag >= 10) {
		return -1;
	}
	len = strlen(value);
	_value = malloc((len+1)*sizeof(char));
	if(_value == NULL) {
		return -1;
	}
	memmove(_value, value, len+1);
	free(f->data.value);
	f->data.value = _value;

	return 0;
}

char * marc_field_get_value(marc_field_t *f)
{
	if(f == NULL || f->tag >= 10) {
		return NULL;
	}

	return f->data.value;
}

marc_subfield_t * marc_field_add_subfield(marc_field_t *f, char code,
	char *value)
{
	marc_subfield_t *s;
	marc_subfield_list_node_t *node;

	if(f == NULL || f->tag < 10) {
		return NULL;
	}
	s = marc_subfield_new(code, value);
	if(s == NULL) {
		return NULL;
	}
	node = marc_subfield_list_add(f->data.subfields, s);
	if(node == NULL) {
		marc_subfield_free(s);
		s = NULL;
	}

	return s;
}

marc_subfield_t * marc_field_pop_subfield(marc_field_t *f, uint32_t pos)
{
	marc_subfield_t *s;

	if(f == NULL || f->tag < 10) {
		return NULL;
	}

	s = marc_subfield_list_pop(f->data.subfields, pos);
	return s;
}

void marc_field_free(marc_field_t *f)
{
	if(f) {
		if(f->tag < 10) {
			free(f->data.value);
		} else {
			marc_subfield_list_free(f->data.subfields);
		}
		free(f);
	}
}

struct marc_field_subfields_iterator_s {
	marc_subfield_list_t *list;
	marc_subfield_list_node_t *node;
};

marc_field_subfields_iterator_t * marc_field_subfields_iterator_new(
	marc_field_t *f)
{
	marc_field_subfields_iterator_t *it;

	if(f == NULL || f->tag < 10) {
		return NULL;
	}

	it = malloc(sizeof(marc_field_subfields_iterator_t));
	if(it == NULL) {
		return NULL;
	}

	it->list = f->data.subfields;
	it->node = NULL;

	return it;
}

int8_t marc_field_subfields_iterator_next(marc_field_subfields_iterator_t *it)
{
	if(it == NULL || it->list == NULL) {
		return -1;
	}
	if(it->node != NULL) {
		if(it->node->next == NULL) {
			return 1;
		}
		it->node = it->node->next;
	} else {
		it->node = it->list->first;
	}

	return 0;
}

marc_subfield_t * marc_field_subfields_iterator_get(
	marc_field_subfields_iterator_t *it)
{
	if(it == NULL || it->list == NULL || it->node == NULL) {
		return NULL;
	}

	return it->node->s;
}

void marc_field_subfields_iterator_free(marc_field_subfields_iterator_t *it)
{
	if(it) {
		free(it);
	}
}

