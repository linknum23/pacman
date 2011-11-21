/**********************************************************************/
/*   ____  ____                                                       */
/*  /   /\/   /                                                       */
/* /___/  \  /                                                        */
/* \   \   \/                                                       */
/*  \   \        Copyright (c) 2003-2009 Xilinx, Inc.                */
/*  /   /          All Right Reserved.                                 */
/* /---/   /\                                                         */
/* \   \  /  \                                                      */
/*  \___\/\___\                                                    */
/***********************************************************************/

/* This file is designed for use with ISim build 0x8ddf5b5d */

#define XSI_HIDE_SYMBOL_SPEC true
#include "xsi.h"
#include <memory.h>
#ifdef __GNUC__
#include <stdlib.h>
#else
#include <malloc.h>
#define alloca _alloca
#endif
static const char *ng0 = "/home/bryant/ise_projects/pacman/dot.vhd";
extern char *IEEE_P_3620187407;
extern char *IEEE_P_1242562249;

int ieee_p_1242562249_sub_1657552908_1035706684(char *, char *, char *);
unsigned char ieee_p_3620187407_sub_2546382208_3965413181(char *, char *, char *, int );


static void work_a_3166408977_3212880686_p_0(char *t0)
{
    char t6[16];
    char t16[16];
    char t28[16];
    char *t1;
    char *t2;
    unsigned int t3;
    unsigned int t4;
    unsigned int t5;
    char *t7;
    char *t8;
    int t9;
    unsigned int t10;
    unsigned char t11;
    char *t12;
    char *t13;
    unsigned int t14;
    unsigned int t15;
    char *t17;
    char *t18;
    int t19;
    unsigned int t20;
    int t21;
    int t22;
    unsigned int t23;
    char *t24;
    unsigned int t25;
    unsigned int t26;
    unsigned int t27;
    char *t29;
    char *t30;
    int t31;
    unsigned int t32;
    int t33;
    int t34;
    unsigned int t35;
    unsigned int t36;
    unsigned int t37;
    unsigned char t38;
    char *t39;
    char *t40;
    char *t41;
    char *t42;
    char *t43;

LAB0:    xsi_set_current_line(30, ng0);
    t1 = (t0 + 592U);
    t2 = *((char **)t1);
    t3 = (5 - 5);
    t4 = (t3 * 1U);
    t5 = (0 + t4);
    t1 = (t2 + t5);
    t7 = (t6 + 0U);
    t8 = (t7 + 0U);
    *((int *)t8) = 5;
    t8 = (t7 + 4U);
    *((int *)t8) = 3;
    t8 = (t7 + 8U);
    *((int *)t8) = -1;
    t9 = (3 - 5);
    t10 = (t9 * -1);
    t10 = (t10 + 1);
    t8 = (t7 + 12U);
    *((unsigned int *)t8) = t10;
    t11 = ieee_p_3620187407_sub_2546382208_3965413181(IEEE_P_3620187407, t1, t6, 7);
    if (t11 != 0)
        goto LAB2;

LAB4:
LAB3:    t1 = (t0 + 1580);
    *((int *)t1) = 1;

LAB1:    return;
LAB2:    xsi_set_current_line(31, ng0);
    t8 = (t0 + 856U);
    t12 = *((char **)t8);
    t8 = (t0 + 592U);
    t13 = *((char **)t8);
    t10 = (5 - 2);
    t14 = (t10 * 1U);
    t15 = (0 + t14);
    t8 = (t13 + t15);
    t17 = (t16 + 0U);
    t18 = (t17 + 0U);
    *((int *)t18) = 2;
    t18 = (t17 + 4U);
    *((int *)t18) = 0;
    t18 = (t17 + 8U);
    *((int *)t18) = -1;
    t19 = (0 - 2);
    t20 = (t19 * -1);
    t20 = (t20 + 1);
    t18 = (t17 + 12U);
    *((unsigned int *)t18) = t20;
    t21 = ieee_p_1242562249_sub_1657552908_1035706684(IEEE_P_1242562249, t8, t16);
    t22 = (t21 - 0);
    t20 = (t22 * 1);
    xsi_vhdl_check_range_of_index(0, 7, 1, t21);
    t23 = (1U * t20);
    t18 = (t0 + 592U);
    t24 = *((char **)t18);
    t25 = (5 - 5);
    t26 = (t25 * 1U);
    t27 = (0 + t26);
    t18 = (t24 + t27);
    t29 = (t28 + 0U);
    t30 = (t29 + 0U);
    *((int *)t30) = 5;
    t30 = (t29 + 4U);
    *((int *)t30) = 3;
    t30 = (t29 + 8U);
    *((int *)t30) = -1;
    t31 = (3 - 5);
    t32 = (t31 * -1);
    t32 = (t32 + 1);
    t30 = (t29 + 12U);
    *((unsigned int *)t30) = t32;
    t33 = ieee_p_1242562249_sub_1657552908_1035706684(IEEE_P_1242562249, t18, t28);
    t34 = (t33 - 0);
    t32 = (t34 * 1);
    xsi_vhdl_check_range_of_index(0, 6, 1, t33);
    t35 = (8U * t32);
    t36 = (0 + t35);
    t37 = (t36 + t23);
    t30 = (t12 + t37);
    t38 = *((unsigned char *)t30);
    t39 = (t0 + 1624);
    t40 = (t39 + 32U);
    t41 = *((char **)t40);
    t42 = (t41 + 32U);
    t43 = *((char **)t42);
    *((unsigned char *)t43) = t38;
    xsi_driver_first_trans_fast_port(t39);
    goto LAB3;

}


extern void work_a_3166408977_3212880686_init()
{
	static char *pe[] = {(void *)work_a_3166408977_3212880686_p_0};
	xsi_register_didat("work_a_3166408977_3212880686", "isim/dot_tb_isim_beh.exe.sim/work/a_3166408977_3212880686.didat");
	xsi_register_executes(pe);
}
