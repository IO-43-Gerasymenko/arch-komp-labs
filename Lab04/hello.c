// SPDX-License-Identifier: GPL-2.0
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
MODULE_PARM_DESC(count, "Number of greetings (0..10, default 1)");

static LIST_HEAD(events);

static void free_events(bool report)
{
	struct hello_event *event, *next;
	unsigned int index = 0;

	list_for_each_entry_safe(event, next, &events, link) {
		if (report)
			printk(KERN_INFO "hello: event %u at %lld ns\n",
			       ++index,
			       (long long)ktime_to_ns(event->timestamp));
		list_del(&event->link);
		kfree(event);
	}
}

static int __init hello_init(void)
{
	unsigned int i;

	if (count > 10) {
		printk(KERN_ERR "hello: count=%u exceeds 10\n", count);
		return -EINVAL;
	}
	if (!count || count >= 5)
		printk(KERN_WARNING "hello: unusual count=%u\n", count);

	for (i = 0; i < count; i++) {
		struct hello_event *event;

		event = kmalloc(sizeof(*event), GFP_KERNEL);
		if (!event) {
			free_events(false);
			return -ENOMEM;
		}
		event->timestamp = ktime_get();
		list_add_tail(&event->link, &events);
		printk(KERN_INFO "hello: Hello, world!\n");
	}
	return 0;
}

static void __exit hello_exit(void)
{
	free_events(true);
}

module_init(hello_init);
module_exit(hello_exit);

MODULE_AUTHOR("Mykhailo Herasymenko");
MODULE_DESCRIPTION("AK2: greeting events with kernel timestamps");
MODULE_LICENSE("GPL");
