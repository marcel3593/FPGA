/**********************************************************************/
/*   ____  ____                                                       */
/*  /   /\/   /                                                       */
/* /___/  \  /                                                        */
/* \   \   \/                                                         */
/*  \   \        Copyright (c) 2003-2013 Xilinx, Inc.                 */
/*  /   /        All Right Reserved.                                  */
/* /---/   /\                                                         */
/* \   \  /  \                                                        */
/*  \___\/\___\                                                       */
/**********************************************************************/


#include "iki.h"
#include <string.h>
#include <math.h>
#ifdef __GNUC__
#include <stdlib.h>
#else
#include <malloc.h>
#define alloca _alloca
#endif
/**********************************************************************/
/*   ____  ____                                                       */
/*  /   /\/   /                                                       */
/* /___/  \  /                                                        */
/* \   \   \/                                                         */
/*  \   \        Copyright (c) 2003-2013 Xilinx, Inc.                 */
/*  /   /        All Right Reserved.                                  */
/* /---/   /\                                                         */
/* \   \  /  \                                                        */
/*  \___\/\___\                                                       */
/**********************************************************************/


#include "iki.h"
#include <string.h>
#include <math.h>
#ifdef __GNUC__
#include <stdlib.h>
#else
#include <malloc.h>
#define alloca _alloca
#endif
typedef void (*funcp)(char *, char *);
extern int main(int, char**);
extern void execute_65(char*, char *);
extern void execute_176(char*, char *);
extern void execute_177(char*, char *);
extern void execute_178(char*, char *);
extern void execute_625(char*, char *);
extern void execute_626(char*, char *);
extern void execute_627(char*, char *);
extern void vlog_simple_process_execute_0_fast_for_reg(char*, char*, char*);
extern void execute_631(char*, char *);
extern void execute_632(char*, char *);
extern void execute_633(char*, char *);
extern void execute_634(char*, char *);
extern void execute_184(char*, char *);
extern void execute_185(char*, char *);
extern void execute_85(char*, char *);
extern void execute_86(char*, char *);
extern void execute_87(char*, char *);
extern void execute_88(char*, char *);
extern void execute_90(char*, char *);
extern void execute_91(char*, char *);
extern void execute_92(char*, char *);
extern void execute_93(char*, char *);
extern void execute_186(char*, char *);
extern void execute_187(char*, char *);
extern void execute_96(char*, char *);
extern void execute_97(char*, char *);
extern void execute_98(char*, char *);
extern void execute_99(char*, char *);
extern void execute_101(char*, char *);
extern void execute_102(char*, char *);
extern void execute_103(char*, char *);
extern void execute_104(char*, char *);
extern void vlog_const_rhs_process_execute_0_fast_no_reg_no_agg(char*, char*, char*);
extern void execute_532(char*, char *);
extern void execute_533(char*, char *);
extern void execute_534(char*, char *);
extern void execute_535(char*, char *);
extern void execute_536(char*, char *);
extern void execute_537(char*, char *);
extern void execute_548(char*, char *);
extern void execute_549(char*, char *);
extern void execute_550(char*, char *);
extern void execute_551(char*, char *);
extern void execute_553(char*, char *);
extern void execute_554(char*, char *);
extern void execute_555(char*, char *);
extern void execute_556(char*, char *);
extern void execute_560(char*, char *);
extern void execute_561(char*, char *);
extern void execute_569(char*, char *);
extern void execute_573(char*, char *);
extern void execute_574(char*, char *);
extern void execute_575(char*, char *);
extern void execute_576(char*, char *);
extern void execute_578(char*, char *);
extern void execute_579(char*, char *);
extern void execute_580(char*, char *);
extern void execute_581(char*, char *);
extern void execute_587(char*, char *);
extern void execute_588(char*, char *);
extern void execute_593(char*, char *);
extern void execute_599(char*, char *);
extern void execute_603(char*, char *);
extern void execute_604(char*, char *);
extern void execute_607(char*, char *);
extern void execute_608(char*, char *);
extern void execute_611(char*, char *);
extern void execute_612(char*, char *);
extern void execute_615(char*, char *);
extern void execute_616(char*, char *);
extern void execute_619(char*, char *);
extern void execute_620(char*, char *);
extern void execute_623(char*, char *);
extern void execute_624(char*, char *);
extern void execute_188(char*, char *);
extern void execute_175(char*, char *);
extern void vlog_simple_process_execute_0_fast_no_reg_no_agg(char*, char*, char*);
extern void vlog_simple_process_execute_1_fast_no_reg_no_agg(char*, char*, char*);
extern void execute_512(char*, char *);
extern void execute_515(char*, char *);
extern void execute_516(char*, char *);
extern void execute_517(char*, char *);
extern void execute_520(char*, char *);
extern void execute_521(char*, char *);
extern void execute_522(char*, char *);
extern void execute_523(char*, char *);
extern void execute_524(char*, char *);
extern void execute_110(char*, char *);
extern void execute_111(char*, char *);
extern void execute_112(char*, char *);
extern void execute_113(char*, char *);
extern void execute_114(char*, char *);
extern void execute_115(char*, char *);
extern void execute_116(char*, char *);
extern void execute_117(char*, char *);
extern void execute_118(char*, char *);
extern void execute_119(char*, char *);
extern void execute_120(char*, char *);
extern void execute_121(char*, char *);
extern void execute_122(char*, char *);
extern void execute_123(char*, char *);
extern void execute_124(char*, char *);
extern void execute_125(char*, char *);
extern void execute_172(char*, char *);
extern void execute_173(char*, char *);
extern void execute_174(char*, char *);
extern void execute_420(char*, char *);
extern void execute_421(char*, char *);
extern void execute_424(char*, char *);
extern void execute_462(char*, char *);
extern void execute_463(char*, char *);
extern void execute_464(char*, char *);
extern void execute_467(char*, char *);
extern void execute_471(char*, char *);
extern void execute_484(char*, char *);
extern void execute_485(char*, char *);
extern void execute_486(char*, char *);
extern void execute_494(char*, char *);
extern void execute_495(char*, char *);
extern void execute_496(char*, char *);
extern void execute_497(char*, char *);
extern void execute_498(char*, char *);
extern void execute_499(char*, char *);
extern void execute_500(char*, char *);
extern void execute_501(char*, char *);
extern void execute_502(char*, char *);
extern void execute_503(char*, char *);
extern void execute_504(char*, char *);
extern void execute_505(char*, char *);
extern void execute_506(char*, char *);
extern void execute_507(char*, char *);
extern void execute_508(char*, char *);
extern void execute_509(char*, char *);
extern void execute_127(char*, char *);
extern void execute_128(char*, char *);
extern void execute_129(char*, char *);
extern void execute_130(char*, char *);
extern void execute_131(char*, char *);
extern void execute_132(char*, char *);
extern void execute_136(char*, char *);
extern void execute_137(char*, char *);
extern void execute_156(char*, char *);
extern void execute_157(char*, char *);
extern void execute_159(char*, char *);
extern void execute_161(char*, char *);
extern void execute_162(char*, char *);
extern void execute_164(char*, char *);
extern void execute_166(char*, char *);
extern void execute_168(char*, char *);
extern void execute_170(char*, char *);
extern void execute_425(char*, char *);
extern void execute_426(char*, char *);
extern void execute_427(char*, char *);
extern void execute_428(char*, char *);
extern void execute_429(char*, char *);
extern void execute_430(char*, char *);
extern void execute_431(char*, char *);
extern void execute_432(char*, char *);
extern void execute_433(char*, char *);
extern void execute_434(char*, char *);
extern void execute_435(char*, char *);
extern void execute_436(char*, char *);
extern void execute_437(char*, char *);
extern void execute_440(char*, char *);
extern void execute_441(char*, char *);
extern void execute_442(char*, char *);
extern void execute_443(char*, char *);
extern void execute_444(char*, char *);
extern void execute_445(char*, char *);
extern void execute_446(char*, char *);
extern void execute_447(char*, char *);
extern void execute_448(char*, char *);
extern void execute_451(char*, char *);
extern void execute_452(char*, char *);
extern void execute_453(char*, char *);
extern void execute_454(char*, char *);
extern void execute_455(char*, char *);
extern void execute_456(char*, char *);
extern void execute_457(char*, char *);
extern void execute_458(char*, char *);
extern void execute_139(char*, char *);
extern void execute_140(char*, char *);
extern void execute_142(char*, char *);
extern void execute_143(char*, char *);
extern void execute_181(char*, char *);
extern void execute_182(char*, char *);
extern void execute_183(char*, char *);
extern void execute_635(char*, char *);
extern void execute_636(char*, char *);
extern void execute_637(char*, char *);
extern void execute_638(char*, char *);
extern void execute_639(char*, char *);
extern void transaction_138(char*, char*, unsigned, unsigned, unsigned);
extern void transaction_159(char*, char*, unsigned, unsigned, unsigned);
extern void vlog_transfunc_eventcallback(char*, char*, unsigned, unsigned, unsigned, char *);
extern void vlog_transfunc_eventcallback_2state(char*, char*, unsigned, unsigned, unsigned, char *);
extern void transaction_146(char*, char*, unsigned, unsigned, unsigned);
extern void transaction_155(char*, char*, unsigned, unsigned, unsigned);
extern void transaction_166(char*, char*, unsigned, unsigned, unsigned);
extern void transaction_175(char*, char*, unsigned, unsigned, unsigned);
funcp funcTab[200] = {(funcp)execute_65, (funcp)execute_176, (funcp)execute_177, (funcp)execute_178, (funcp)execute_625, (funcp)execute_626, (funcp)execute_627, (funcp)vlog_simple_process_execute_0_fast_for_reg, (funcp)execute_631, (funcp)execute_632, (funcp)execute_633, (funcp)execute_634, (funcp)execute_184, (funcp)execute_185, (funcp)execute_85, (funcp)execute_86, (funcp)execute_87, (funcp)execute_88, (funcp)execute_90, (funcp)execute_91, (funcp)execute_92, (funcp)execute_93, (funcp)execute_186, (funcp)execute_187, (funcp)execute_96, (funcp)execute_97, (funcp)execute_98, (funcp)execute_99, (funcp)execute_101, (funcp)execute_102, (funcp)execute_103, (funcp)execute_104, (funcp)vlog_const_rhs_process_execute_0_fast_no_reg_no_agg, (funcp)execute_532, (funcp)execute_533, (funcp)execute_534, (funcp)execute_535, (funcp)execute_536, (funcp)execute_537, (funcp)execute_548, (funcp)execute_549, (funcp)execute_550, (funcp)execute_551, (funcp)execute_553, (funcp)execute_554, (funcp)execute_555, (funcp)execute_556, (funcp)execute_560, (funcp)execute_561, (funcp)execute_569, (funcp)execute_573, (funcp)execute_574, (funcp)execute_575, (funcp)execute_576, (funcp)execute_578, (funcp)execute_579, (funcp)execute_580, (funcp)execute_581, (funcp)execute_587, (funcp)execute_588, (funcp)execute_593, (funcp)execute_599, (funcp)execute_603, (funcp)execute_604, (funcp)execute_607, (funcp)execute_608, (funcp)execute_611, (funcp)execute_612, (funcp)execute_615, (funcp)execute_616, (funcp)execute_619, (funcp)execute_620, (funcp)execute_623, (funcp)execute_624, (funcp)execute_188, (funcp)execute_175, (funcp)vlog_simple_process_execute_0_fast_no_reg_no_agg, (funcp)vlog_simple_process_execute_1_fast_no_reg_no_agg, (funcp)execute_512, (funcp)execute_515, (funcp)execute_516, (funcp)execute_517, (funcp)execute_520, (funcp)execute_521, (funcp)execute_522, (funcp)execute_523, (funcp)execute_524, (funcp)execute_110, (funcp)execute_111, (funcp)execute_112, (funcp)execute_113, (funcp)execute_114, (funcp)execute_115, (funcp)execute_116, (funcp)execute_117, (funcp)execute_118, (funcp)execute_119, (funcp)execute_120, (funcp)execute_121, (funcp)execute_122, (funcp)execute_123, (funcp)execute_124, (funcp)execute_125, (funcp)execute_172, (funcp)execute_173, (funcp)execute_174, (funcp)execute_420, (funcp)execute_421, (funcp)execute_424, (funcp)execute_462, (funcp)execute_463, (funcp)execute_464, (funcp)execute_467, (funcp)execute_471, (funcp)execute_484, (funcp)execute_485, (funcp)execute_486, (funcp)execute_494, (funcp)execute_495, (funcp)execute_496, (funcp)execute_497, (funcp)execute_498, (funcp)execute_499, (funcp)execute_500, (funcp)execute_501, (funcp)execute_502, (funcp)execute_503, (funcp)execute_504, (funcp)execute_505, (funcp)execute_506, (funcp)execute_507, (funcp)execute_508, (funcp)execute_509, (funcp)execute_127, (funcp)execute_128, (funcp)execute_129, (funcp)execute_130, (funcp)execute_131, (funcp)execute_132, (funcp)execute_136, (funcp)execute_137, (funcp)execute_156, (funcp)execute_157, (funcp)execute_159, (funcp)execute_161, (funcp)execute_162, (funcp)execute_164, (funcp)execute_166, (funcp)execute_168, (funcp)execute_170, (funcp)execute_425, (funcp)execute_426, (funcp)execute_427, (funcp)execute_428, (funcp)execute_429, (funcp)execute_430, (funcp)execute_431, (funcp)execute_432, (funcp)execute_433, (funcp)execute_434, (funcp)execute_435, (funcp)execute_436, (funcp)execute_437, (funcp)execute_440, (funcp)execute_441, (funcp)execute_442, (funcp)execute_443, (funcp)execute_444, (funcp)execute_445, (funcp)execute_446, (funcp)execute_447, (funcp)execute_448, (funcp)execute_451, (funcp)execute_452, (funcp)execute_453, (funcp)execute_454, (funcp)execute_455, (funcp)execute_456, (funcp)execute_457, (funcp)execute_458, (funcp)execute_139, (funcp)execute_140, (funcp)execute_142, (funcp)execute_143, (funcp)execute_181, (funcp)execute_182, (funcp)execute_183, (funcp)execute_635, (funcp)execute_636, (funcp)execute_637, (funcp)execute_638, (funcp)execute_639, (funcp)transaction_138, (funcp)transaction_159, (funcp)vlog_transfunc_eventcallback, (funcp)vlog_transfunc_eventcallback_2state, (funcp)transaction_146, (funcp)transaction_155, (funcp)transaction_166, (funcp)transaction_175};
const int NumRelocateId= 200;

void relocate(char *dp)
{
	iki_relocate(dp, "xsim.dir/tb_fifo_behav/xsim.reloc",  (void **)funcTab, 200);

	/*Populate the transaction function pointer field in the whole net structure */
}

void sensitize(char *dp)
{
	iki_sensitize(dp, "xsim.dir/tb_fifo_behav/xsim.reloc");
}

	// Initialize Verilog nets in mixed simulation, for the cases when the value at time 0 should be propagated from the mixed language Vhdl net

void wrapper_func_0(char *dp)

{

}

void simulate(char *dp)
{
iki_register_root_pointers(9, 124944, -5,0,125784, -5,0,123936, -5,0,124776, -5,0,127464, -7,0,129488, -7,0,131680, -7,0,133704, -7,0,169856, 31,0) ; 
		iki_schedule_processes_at_time_zero(dp, "xsim.dir/tb_fifo_behav/xsim.reloc");
	wrapper_func_0(dp);

	iki_execute_processes();

	// Schedule resolution functions for the multiply driven Verilog nets that have strength
	// Schedule transaction functions for the singly driven Verilog nets that have strength

}
#include "iki_bridge.h"
void subprog_m_eafc9399_6a8752bf_6() ;
void subprog_m_eafc9399_6a8752bf_5() ;
void subprog_m_eafc9399_6a8752bf_4() ;
void subprog_m_eafc9399_6a8752bf_3() ;
void subprog_m_eafc9399_6a8752bf_9() ;
void subprog_m_eafc9399_6a8752bf_36() ;
void subprog_m_eafc9399_6a8752bf_35() ;
void subprog_m_eafc9399_6a8752bf_34() ;
void subprog_m_eafc9399_6a8752bf_40() ;
void subprog_m_eafc9399_6a8752bf_39() ;
void subprog_m_eafc9399_6a8752bf_38() ;
void subprog_m_7bfcba4f_31d5efce_65() ;
void subprog_m_7bfcba4f_31d5efce_64() ;
void subprog_m_7bfcba4f_31d5efce_63() ;
void subprog_m_7bfcba4f_31d5efce_62() ;
static char* ng30[] = {(void *)subprog_m_eafc9399_6a8752bf_6, (void *)subprog_m_eafc9399_6a8752bf_5, (void *)subprog_m_eafc9399_6a8752bf_4, (void *)subprog_m_eafc9399_6a8752bf_3};
static char* ng60[] = {(void *)subprog_m_eafc9399_6a8752bf_9};
static char* ng140[] = {(void *)subprog_m_eafc9399_6a8752bf_36, (void *)subprog_m_eafc9399_6a8752bf_35, (void *)subprog_m_eafc9399_6a8752bf_34};
static char* ng150[] = {(void *)subprog_m_eafc9399_6a8752bf_40, (void *)subprog_m_eafc9399_6a8752bf_39, (void *)subprog_m_eafc9399_6a8752bf_38};
static char* ng310[] = {(void *)subprog_m_7bfcba4f_31d5efce_65, (void *)subprog_m_7bfcba4f_31d5efce_64, (void *)subprog_m_7bfcba4f_31d5efce_63, (void *)subprog_m_7bfcba4f_31d5efce_62};
void relocate(char *);

void sensitize(char *);

void simulate(char *);

extern SYSTEMCLIB_IMP_DLLSPEC void local_register_implicit_channel(int, char*);
extern void implicit_HDL_SCinstatiate();

extern SYSTEMCLIB_IMP_DLLSPEC int xsim_argc_copy ;
extern SYSTEMCLIB_IMP_DLLSPEC char** xsim_argv_copy ;

int main(int argc, char **argv)
{
    iki_heap_initialize("ms", "isimmm", 0, 2147483648) ;
    iki_set_sv_type_file_path_name("xsim.dir/tb_fifo_behav/xsim.svtype");
    iki_set_crvs_dump_file_path_name("xsim.dir/tb_fifo_behav/xsim.crvsdump");
    iki_svlog_initialize_virtual_tables(5, 3, ng30, 6, ng60, 14, ng140, 15, ng150, 31, ng310);
    void* design_handle = iki_create_design("xsim.dir/tb_fifo_behav/xsim.mem", (void *)relocate, (void *)sensitize, (void *)simulate, 0, isimBridge_getWdbWriter(), 0, argc, argv);
     iki_set_rc_trial_count(100);
    (void) design_handle;
    return iki_simulate_design();
}
