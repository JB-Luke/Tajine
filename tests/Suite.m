%% Test Suite
import matlab.unittest.TestSuite
import matlab.unittest.selectors.HasTag

suite = TestSuite.fromFolder("tests");

% unitTestSuite = suite.selectIf(HasTag('Unit'));
% results = run(unitTestSuite);

results = run(suite);

% disp(table(results))