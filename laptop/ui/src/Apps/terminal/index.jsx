import React, { useEffect, useState, useRef } from "react"
import { makeStyles } from "@mui/styles"
import Nui from "../../util/Nui"

const useStyles = makeStyles((theme) => ({
  wrapper: {
    height: "100%",
    background: "#000",
    color: "#0f0",
    fontFamily: "monospace",
    padding: "10px",
    overflow: "auto",
  },
  terminalContent: {
    whiteSpace: "pre-wrap",
    wordBreak: "break-word",
  },
  inputLine: {
    display: "flex",
    alignItems: "center",
  },
  prompt: {
    marginRight: "8px",
  },
  input: {
    background: "transparent",
    border: "none",
    color: "#0f0",
    fontFamily: "monospace",
    fontSize: "inherit",
    flex: 1,
    outline: "none",
    caretColor: "#0f0",
  },
  errorText: {
    color: "#f00",
  },
  warningText: {
    color: "#ff0",
  },
}))

export default () => {
  const classes = useStyles()
  const [history, setHistory] = useState([
    "Welcome to SKDEV Terminal v1.0.0",
    'Type "skdev -help" for available commands',
  ])
  const [input, setInput] = useState("")
  const [isProcessing, setIsProcessing] = useState(false)
  const [isUpgraded, setIsUpgraded] = useState(false)
  const [version, setVersion] = useState("1.0.0")
  const [installedApps, setInstalledApps] = useState([])
  const inputRef = useRef(null)
  const terminalRef = useRef(null)

  // Auto-focus the input when component mounts
  useEffect(() => {
    if (inputRef.current) {
      inputRef.current.focus()
    }
  }, [])

  // Scroll to bottom when history changes
  useEffect(() => {
    if (terminalRef.current) {
      terminalRef.current.scrollTop = terminalRef.current.scrollHeight
    }
  }, [history])

  const handleInputChange = (e) => {
    setInput(e.target.value)
  }

  const handleKeyDown = (e) => {
    if (e.key === "Enter" && !isProcessing) {
      processCommand()
    }
  }

  // Function to add lines gradually with a delay
  const addLinesWithDelay = (lines, callback = null) => {
    if (lines.length === 0) {
      if (callback) callback()
      return
    }

    setIsProcessing(true)
    let currentIndex = 0

    const addNextLine = () => {
      if (currentIndex < lines.length) {
        setHistory((prev) => [...prev, lines[currentIndex]])
        currentIndex++

        // Calculate a slightly random delay between 200-500ms for more realism
        const delay = Math.floor(Math.random() * 300) + 200
        setTimeout(addNextLine, delay)
      } else {
        if (callback) {
          callback()
        } else {
          setIsProcessing(false)
        }
      }
    }

    addNextLine()
  }

  const processCommand = () => {
    const fullCommand = input.trim()
    // Add the command to history
    setHistory((prev) => [...prev, `user@skdev:~$ ${input}`])
    setInput("")

    // Split command into parts
    const parts = fullCommand.split(" ")
    const baseCommand = parts[0]

    // Handle non-skdev commands
    if (baseCommand !== "skdev" && fullCommand !== "") {
      addLinesWithDelay([`bash: ${baseCommand}: command not found`, 'Type "skdev -help" for available commands'])
      return
    }

    // Handle empty skdev command
    if (fullCommand === "skdev") {
      addLinesWithDelay(["Usage: skdev [OPTION] [APP]", 'Try "skdev -help" for more information.'])
      return
    }

    const subCommand = parts[1]

    // Process different commands
    if (subCommand === "-help" || subCommand === "--help") {
      const helpLines = [
        "SKDEV Terminal Help:",
        "  skdev -help                 Show this help message",
        "  skdev upgrade               Upgrade SKDEV to the latest version",
        "  skdev install <app>         Install an application",
        "  skdev list                  List available applications",
        "  skdev status                Show system status",
        "  skdev uninstall <app>       Uninstall an application",
      ]
      addLinesWithDelay(helpLines)
    } else if (subCommand === "upgrade") {
      if (parts.length > 2) {
        addLinesWithDelay([
          "skdev: too many arguments",
          "Usage: skdev upgrade",
          'Try "skdev -help" for more information.',
        ])
        return
      }

      if (!isUpgraded) {
        const upgradeLines = [
          "Checking for updates...",
          "Found SKDEV v1.1.0 (Current: v1.0.0)",
          "Downloading updates...",
          "[====================] 100%",
          "Installing updates...",
          "Updating system components...",
          "Updating core libraries...",
          "Updating application registry...",
          "Upgrade complete! SKDEV is now at version 1.1.0",
        ]
        addLinesWithDelay(upgradeLines, () => {
          setIsUpgraded(true)
          setVersion("1.1.0")
          setIsProcessing(false)
        })
      } else {
        const alreadyUpgradedLines = [
          "Checking for updates...",
          `SKDEV is already at the latest version (v${version})`,
          "No updates available at this time.",
        ]
        addLinesWithDelay(alreadyUpgradedLines)
      }
    } else if (subCommand === "install") {
      if (parts.length < 3) {
        addLinesWithDelay([
          "skdev: missing application name",
          "Usage: skdev install <app>",
          'Try "skdev list" to see available applications.',
        ])
        return
      }

      const app = parts[2]
      const availableApps = ["gangs", "heists"]

      if (!availableApps.includes(app)) {
        addLinesWithDelay([
          `skdev: application '${app}' not found in registry`,
          'Try "skdev list" to see available applications.',
        ])
        return
      }

      if (installedApps.includes(app)) {
        addLinesWithDelay([`skdev: '${app}' is already installed`, 'Try "skdev status" to see installed applications.'])
        return
      }

      // Only allow installing the "gangs" app
      if (app === "gangs") {
        const initialLines = [
          `Installing ${app}...`,
          "[====================] 100%",
          "Configuring application...",
          "Setting up dependencies...",
          "Waiting for system confirmation...",
        ]

        addLinesWithDelay(initialLines, async () => {
          try {
            // Send NUI message and wait for response
            const response = await Nui.send("Unknown/InstallApp", { app: "gangs" })
            const result = await response.json()

            if (result && result.success) {
              // Installation successful
              setHistory((prev) => [...prev, `${app} has been successfully installed!`])
              setInstalledApps([...installedApps, app])
            } else {
              // Installation failed
              setHistory((prev) => [
                ...prev,
                `Installation failed: ${result.message || "Unknown error"}`,
                "Try again later or contact system administrator.",
              ])
            }
          } catch (error) {
            // Error during installation
            setHistory((prev) => [
              ...prev,
              "Installation failed: Connection error",
              "Try again later or contact system administrator.",
            ])
          } finally {
            setIsProcessing(false)
          }
        })
      } else {
        // Permission denied for other apps
        addLinesWithDelay([
          `skdev: Permission denied: You don't have permission to install '${app}'`,
          "Contact your system administrator for access.",
        ])
      }
	  if (app === "heists") {
        const initialLines = [
          `Installing ${app}...`,
          "[====================] 100%",
          "Configuring application...",
          "Setting up dependencies...",
          "Waiting for system confirmation...",
        ]

        addLinesWithDelay(initialLines, async () => {
          try {
            // Send NUI message and wait for response
            const response = await Nui.send("Unknown/InstallApp", { app: "heists" })
            const result = await response.json()

            if (result && result.success) {
              // Installation successful
              setHistory((prev) => [...prev, `${app} has been successfully installed!`])
              setInstalledApps([...installedApps, app])
            } else {
              // Installation failed
              setHistory((prev) => [
                ...prev,
                `Installation failed: ${result.message || "Unknown error"}`,
                "Try again later or contact system administrator.",
              ])
            }
          } catch (error) {
            // Error during installation
            setHistory((prev) => [
              ...prev,
              "Installation failed: Connection error",
              "Try again later or contact system administrator.",
            ])
          } finally {
            setIsProcessing(false)
          }
        })
      } else {
        // Permission denied for other apps
        addLinesWithDelay([
          `skdev: Permission denied: You don't have permission to install '${app}'`,
          "Contact your system administrator for access.",
        ])
      }
    } else if (subCommand === "list") {
      if (parts.length > 2) {
        addLinesWithDelay(["skdev: too many arguments", "Usage: skdev list", 'Try "skdev -help" for more information.'])
        return
      }

      const listLines = [
        "Available applications:",
        "  gangs       - Team management system" + (installedApps.includes("gangs") ? " [INSTALLED]" : ""),
        "  heists   - Heists System" + (installedApps.includes("heists") ? " [INSTALLED]" : "") + " [REQUIRES PERMISSION]",
        "  tracker     - GPS tracking system" + (installedApps.includes("tracker") ? " [INSTALLED]" : "") + " [REQUIRES PERMISSION]",
        "  crypto      - Cryptocurrency manager" + (installedApps.includes("crypto") ? " [INSTALLED]" : "") + " [REQUIRES PERMISSION]",
        "  darkweb     - Anonymous marketplace" + (installedApps.includes("darkweb") ? " [INSTALLED]" : "") + " [REQUIRES PERMISSION]",
      ]
      addLinesWithDelay(listLines)
    } else if (subCommand === "status") {
      if (parts.length > 2) {
        addLinesWithDelay([
          "skdev: too many arguments",
          "Usage: skdev status",
          'Try "skdev -help" for more information.',
        ])
        return
      }

      const installedAppsText = installedApps.length > 0 ? installedApps.join(", ") : "None"

      const statusLines = [
        "SKDEV System Status:",
        `  Version:    ${version}`,
        "  CPU Usage:  23%",
        "  Memory:     512MB / 1024MB",
        "  Uptime:     3d 7h 22m",
        "  Services:   All operational",
        `  Installed:  ${installedAppsText}`,
      ]
      addLinesWithDelay(statusLines)
    } else if (subCommand === "uninstall") {
      if (parts.length < 3) {
        addLinesWithDelay([
          "skdev: missing application name",
          "Usage: skdev uninstall <app>",
          'Try "skdev status" to see installed applications.',
        ])
        return
      }

      const app = parts[2]

      if (!installedApps.includes(app)) {
        addLinesWithDelay([`skdev: '${app}' is not installed`, 'Try "skdev status" to see installed applications.'])
        return
      }

      const uninstallLines = [
        `Uninstalling ${app}...`,
        "Removing application files...",
        "Cleaning up dependencies...",
        `${app} has been successfully uninstalled!`,
      ]

      addLinesWithDelay(uninstallLines, () => {
        setInstalledApps(installedApps.filter((a) => a !== app))
        setIsProcessing(false)
      })
    } else {
      addLinesWithDelay([`skdev: unknown option '${subCommand}'`, 'Try "skdev -help" for more information.'])
    }
  }

  const handleTerminalClick = () => {
    if (inputRef.current && !isProcessing) {
      inputRef.current.focus()
    }
  }

  return (
    <div className={classes.wrapper} onClick={handleTerminalClick} ref={terminalRef}>
      <div className={classes.terminalContent}>
        {history.map((line, index) => {
          // Check if this is an error message
          const isError =
            line.includes("not found") ||
            line.includes("unknown option") ||
            line.includes("too many arguments") ||
            line.includes("missing application") ||
            line.includes("Permission denied") ||
            line.includes("Installation failed")

          // Check if this is a warning message
          const isWarning = line.includes("Waiting for system confirmation")

          let className = ""
          if (isError) className = classes.errorText
          else if (isWarning) className = classes.warningText

          return (
            <div key={index} className={className}>
              {line}
            </div>
          )
        })}
      </div>
      {!isProcessing && (
        <div className={classes.inputLine}>
          <span className={classes.prompt}>user@skdev:~$</span>
          <input
            ref={inputRef}
            type="text"
            className={classes.input}
            value={input}
            onChange={handleInputChange}
            onKeyDown={handleKeyDown}
            autoFocus
          />
        </div>
      )}
      {isProcessing && (
        <div className={classes.inputLine}>
          <span className={classes.prompt}>Processing...</span>
        </div>
      )}
    </div>
  )
}