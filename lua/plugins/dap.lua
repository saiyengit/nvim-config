-- Debugger: nvim-dap + dap-ui + inline variable values
-- (from s-i-m-g/nvim lua/plugins/dap.lua). Adapter is gdb (>= 14) via its
-- built-in DAP interface.
--
--   <leader>dc  start / continue     <leader>db  toggle breakpoint
--   <leader>di  step into            <leader>dB  breakpoint with condition
--   <leader>dO  step over            <leader>dr  open debug REPL
--   <leader>do  step out             <leader>du  toggle the UI
--   <leader>dl  re-run last config   <leader>dt  terminate session
--   <leader>de  eval expr (n / v)
return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      dapui.setup()
      require("nvim-dap-virtual-text").setup({})

      -- gutter signs
      local sign = vim.fn.sign_define
      sign("DapBreakpoint", { text = "●", texthl = "DiagnosticError" })
      sign("DapBreakpointCondition", { text = "◆", texthl = "DiagnosticWarn" })
      sign("DapStopped", { text = "▶", texthl = "DiagnosticOk", linehl = "Visual" })
      sign("DapBreakpointRejected", { text = "○", texthl = "DiagnosticError" })

      -- open / close the UI automatically with the session
      dap.listeners.after.event_initialized["dapui"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui"] = function() dapui.close() end
      dap.listeners.before.event_exited["dapui"] = function() dapui.close() end

      -- adapter
      dap.adapters.gdb = {
        type = "executable",
        command = "gdb",
        args = { "--interpreter=dap", "--eval-command", "set print pretty on" },
      }

      -- compile the current file with debug info, return the exe path (or nil)
      local function build_current()
        vim.cmd("silent! write")
        local src = vim.fn.expand("%:p")
        local exe = vim.fn.expand("%:p:r")
        local out = vim.fn.systemlist({ "cc", "-g", "-Wall", "-Wextra", src, "-o", exe })
        if vim.v.shell_error ~= 0 then
          vim.notify(table.concat(out, "\n"), vim.log.levels.ERROR, { title = "cc failed" })
          return nil
        end
        return exe
      end

      dap.configurations.c = {
        {
          name = "Build & debug current file",
          type = "gdb",
          request = "launch",
          program = build_current,
          cwd = "${fileDirname}",
          stopAtBeginningOfMainSubprogram = false,
        },
        {
          name = "Debug an executable (pick path)",
          type = "gdb",
          request = "launch",
          program = function()
            return vim.fn.input("Executable: ", vim.fn.getcwd() .. "/", "file")
          end,
          cwd = "${workspaceFolder}",
        },
        {
          name = "Attach to running process",
          type = "gdb",
          request = "attach",
          processId = require("dap.utils").pick_process,
          cwd = "${workspaceFolder}",
        },
      }
      dap.configurations.cpp = dap.configurations.c

      -- keymaps
      local map = vim.keymap.set
      map("n", "<leader>dc", dap.continue, { desc = "Start / continue" })
      map("n", "<leader>dO", dap.step_over, { desc = "Step over" })
      map("n", "<leader>di", dap.step_into, { desc = "Step into" })
      map("n", "<leader>do", dap.step_out, { desc = "Step out" })
      map("n", "<leader>db", dap.toggle_breakpoint, { desc = "Toggle breakpoint" })
      map("n", "<leader>dB", function()
        dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
      end, { desc = "Conditional breakpoint" })
      map("n", "<leader>dr", dap.repl.toggle, { desc = "Debug REPL" })
      map("n", "<leader>du", dapui.toggle, { desc = "Toggle debug UI" })
      map("n", "<leader>dt", dap.terminate, { desc = "Terminate debug session" })
      map("n", "<leader>dl", dap.run_last, { desc = "Re-run last debug config" })
      map({ "n", "v" }, "<leader>de", function()
        dapui.eval(nil, { enter = true })
      end, { desc = "Evaluate expression" })
    end,
  },
}
