import os
import subprocess
import filecmp

COMMON_TESTS = [
		"Abs_tb",
		"FreqDivider_tb",
		"IntSqrt_tb",
		"PulseGen_tb",
		"Pwm_tb",
		"TriggeredTimer_tb",
		"PositionKeeper_tb",
		"QuadrantFinder_tb"
		]

BRAM_TESTS = [
		"Bram_tb",
		"BramFifoCtrl_tb",
		"BramReader_tb",
		"FifoBuffer_tb"
		]

MOTORS_TESTS = [
		"MotorsCtrl_tb",
		"ServoCtrl_tb",
		"StepperCtrlXY_tb",
		"StepperCtrl_tb"
		]

PROCESSOR_TESTS = [
		"CircularOpHandler_DirectionFinder_tb",
		"CircularOpHandler_NumStepsCalculator_tb",
		"CircularOpHandler_tb",
		"DummyOpHandler_tb",
		"LinearOpHandler_tb",
		"OpHandlerInputChooser_tb",
		"OpHandlerOutputChooser_tb",
		"ProcessorTop_tb",
		"PulseNumMultiplier_tb"
		]

PARSER_TESTS = [
		"CharDecoder_tb",
		"AsciiToDigit_tb",
		"NumberBuilder_tb",
		"OpBuilder_tb",
		"ArgSizeCheck_tb",
		"CircularFlagsBuilder_tb"
		]

TESTS = COMMON_TESTS + BRAM_TESTS + MOTORS_TESTS + PROCESSOR_TESTS + PARSER_TESTS

REFS_DIR = "tests/refs"
TESTS_DIR = "tests/tests"

def run_one_sim(test):
	h = subprocess.Popen(['vsim', '-c', '-nolog', "out." + test, '-do', 'run -all'], stdout=subprocess.DEVNULL)
	h.wait()

def run_all_sims():
	print("REMOVING old test files...")
	for test in TESTS:
		test_file = os.path.join(TESTS_DIR, test + ".txt")
		try:
			os.remove(test_file)
		except OSError:
			pass

	for test in TESTS:
		print("RUNNING simulation '{0}'".format(test))
		run_one_sim(test)

	print("DONE running simulations...")

def run_one_test(refs_dir, tests_dir, test):
	ref_file = os.path.join(refs_dir, test + ".txt")
	test_file = os.path.join(tests_dir, test + ".txt")
	try:
		return filecmp.cmp(ref_file, test_file, shallow=False)
	except OSError:
		return False

def run_all_tests():
	passed = 0
	failed = 0
	for test in TESTS:
		result = run_one_test(REFS_DIR, TESTS_DIR, test)
		if result:
			print("[PASSED] {0}".format(test))
			passed += 1
		else:
			print("[FAILED] {0}".format(test))
			failed += 1

	print("DONE running tests...")
	print("Passed: {0}".format(passed))
	print("Failed: {0}".format(failed))

def main():
	run_all_sims()
	run_all_tests()

if __name__ == "__main__":
	main()
