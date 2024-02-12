vim.keymap.set("n", "<leader>cb", function() vim.cmd("te ssh samlan@host.docker.internal -p 2202 'cd /work/as-jct/configuration ; compile'") end)
vim.keymap.set("n", "<leader>cbt", function() vim.cmd("te ssh samlan@host.docker.internal -p 2202 'cd /work/as-jct/configuration ; runTests'") end)
