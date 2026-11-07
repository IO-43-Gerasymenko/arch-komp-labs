// SPDX-License-Identifier: GPL-2.0
#include <linux/bug.h>
#include <linux/init.h>
#include <linux/ktime.h>
#include <linux/list.h>
#include <linux/module.h>
#include <linux/moduleparam.h>
#include <linux/slab.h>

struct hello_event {
	struct list_head link;
	ktime_t timestamp;
};

static unsigned int count = 1;
module_param(count, uint, 0444);
MODULE_PARM_DESC(count, "Greeting count; >10 triggers BUG, 5th event fails");

static LIST_HEAD(events);

static noinline void record_event(struct hello_event *event)
{
	event->timestamp = ktime_get();
	list_add_tail(&event->link, &events);
}

static int __init hello_init(void)
{
	unsigned int i;

	BUG_ON(count > 10);
	if (!count || count >= 5)
		pr_warn("hello: unusual count=%u\n", count);

	for (i = 0; i < count; i++) {
		struct hello_event *event;

		/* Deliberate fault injection for the fifth greeting. */
		if (i == 4)
			event = NULL;
		else
			event = kmalloc(sizeof(*event), GFP_KERNEL);
		record_event(event);
		pr_info("hello: Hello, world!\n");
	}
	return 0;
}

static void __exit hello_exit(void)
{
	struct hello_event *event, *next;
	unsigned int index = 0;

	list_for_each_entry_safe(event, next, &events, link) {
		pr_info("hello: event %u at %lld ns\n", ++index,
			(long long)ktime_to_ns(event->timestamp));
		list_del(&event->link);
		kfree(event);
	}
}

module_init(hello_init);
module_exit(hello_exit);

MODULE_AUTHOR("Mykhailo Herasymenko");
MODULE_DESCRIPTION("AK2: isolated QEMU kernel fault debugging exercise");
MODULE_LICENSE("GPL");
