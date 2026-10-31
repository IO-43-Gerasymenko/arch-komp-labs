// SPDX-License-Identifier: GPL-2.0
#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt

#include <linux/init.h>
#include <linux/module.h>
#include <linux/moduleparam.h>

#include "hello1.h"

static unsigned int count = 1;
module_param(count, uint, 0444);
MODULE_PARM_DESC(count, "Number of greetings (0..10, default 1)");

static int __init hello2_init(void)
{
	unsigned int i;
	int ret;

	if (count > 10) {
		pr_err("count=%u exceeds 10\n", count);
		return -EINVAL;
	}
	if (!count || count >= 5)
		pr_warn("unusual count=%u\n", count);

	for (i = 0; i < count; i++) {
		ret = print_hello();
		if (ret)
			return ret;
	}
	return 0;
}

static void __exit hello2_exit(void)
{
	pr_info("consumer unloaded\n");
}

module_init(hello2_init);
module_exit(hello2_exit);

MODULE_AUTHOR("Mykhailo Herasymenko");
MODULE_DESCRIPTION("AK2: greeting consumer using hello1");
MODULE_LICENSE("GPL");
