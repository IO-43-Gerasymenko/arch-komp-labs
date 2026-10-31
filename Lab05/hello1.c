// SPDX-License-Identifier: GPL-2.0
#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt

#include <linux/init.h>
#include <linux/ktime.h>
#include <linux/list.h>
#include <linux/module.h>
#include <linux/slab.h>

#include "hello1.h"

struct hello_event {
	struct list_head link;
	ktime_t before;
	ktime_t after;
};

static LIST_HEAD(events);

int print_hello(void)
{
	struct hello_event *event;

	event = kmalloc(sizeof(*event), GFP_KERNEL);
	if (!event)
		return -ENOMEM;
	list_add_tail(&event->link, &events);
	event->before = ktime_get();
	pr_info("Hello, world!\n");
	event->after = ktime_get();
	return 0;
}
EXPORT_SYMBOL(print_hello);

static int __init hello1_init(void)
{
	pr_info("provider loaded\n");
	return 0;
}

static void __exit hello1_exit(void)
{
	struct hello_event *event, *next;
	unsigned int index = 0;

	list_for_each_entry_safe(event, next, &events, link) {
		pr_info("event %u: print duration %lld ns\n", ++index,
			(long long)ktime_to_ns(ktime_sub(event->after,
						       event->before)));
		list_del(&event->link);
		kfree(event);
	}
	pr_info("provider unloaded\n");
}

module_init(hello1_init);
module_exit(hello1_exit);

MODULE_AUTHOR("Mykhailo Herasymenko");
MODULE_DESCRIPTION("AK2: exported greeting function and event list");
MODULE_LICENSE("GPL");
