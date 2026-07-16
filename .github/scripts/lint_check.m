% Basic MATLAB syntax check for CI.
%
% Verifies every .m file in the repo at least parses (via pcode, which
% must fully compile a file to produce P-code and so fails cleanly on a
% genuine syntax error). checkcode's style/lint suggestions are printed
% as non-blocking informational output -- this repo has no test suite,
% so the CI gate here is "does every file parse", not "is every file
% idiomatic".

files = dir(fullfile(pwd, '**', '*.m'));
files = files(~[files.isdir]);

outDir = tempname;
mkdir(outDir);

failures = {};
for i = 1:numel(files)
    fp = fullfile(files(i).folder, files(i).name);
    try
        pcode(fp, '-outdir', outDir);
    catch ME
        failures{end+1} = sprintf('%s: %s', fp, ME.message); %#ok<AGROW>
    end

    issues = checkcode(fp);
    for j = 1:numel(issues)
        fprintf('[checkcode] %s:%d: %s\n', fp, issues(j).line, issues(j).message);
    end
end

rmdir(outDir, 's');

if ~isempty(failures)
    fprintf(2, '\n%d file(s) failed to parse:\n', numel(failures));
    for i = 1:numel(failures)
        fprintf(2, '  %s\n', failures{i});
    end
    error('lint_check:SyntaxError', 'MATLAB syntax check failed.');
end

fprintf('\nAll %d .m files parsed successfully.\n', numel(files));
