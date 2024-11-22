-- 获取应用程序所在位置
set appPath to POSIX path of (path to me)
set appResourcesPath to appPath & "Contents/Resources/"

-- 定义存储文件路径
set plistFilePath to appResourcesPath & "MarginNote4EraserProConfig.plist"

-- 定义默认值
set defaultIndexOfEraser to 4

-- 函数：读取配置文件
on readPlistConfig(filePath)
	try
		tell application "System Events"
			set plistData to property list file filePath
			set eraserIndex to value of property list item "indexOfEraser" of plistData
			return eraserIndex as integer
		end tell
	on error errMsg
		display dialog "读取配置文件时出错：" & errMsg
		return ""
	end try
end readPlistConfig

-- 函数: 检查MN4是否是屏幕焦点
on setMN4Front()
	try
		tell application "System Events"
			if not frontmost of process "MarginNote 4" then
				set frontmost of process "MarginNote 4" to true
			end if
		end tell
	on error errMsg
		display dialog "MarginNote 4 窗口置顶失败: " & errMag
	end try
end setMN4Front

-- 检查配置文件是否存在并读取配置
set indexOfEraser to ""
try
	set indexOfEraser to readPlistConfig(plistFilePath)
	if indexOfEraser is "" then error "配置文件为空"
on error errMsg
	-- 配置文件不存在或无效，提示用户输入
	display dialog "配置文件读取失败：" & errMsg
	set userInput to display dialog "请输入橡皮擦按钮的序号（从1开始）：" default answer (defaultIndexOfEraser as string)
	set indexOfEraser to text returned of userInput as integer
	-- 将用户输入的值存储到配置文件
	set configContent to "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
<plist version=\"1.0\">
<dict>
	<key>indexOfEraser</key>
	<integer>" & indexOfEraser & "</integer>
</dict>
</plist>"
	try
		do shell script "echo " & quoted form of configContent & " > " & quoted form of plistFilePath
	on error writeErrMsg
		display dialog "无法写入配置文件：" & writeErrMsg
	end try
end try

-- 确保 indexOfEraser 是整数
set indexOfEraser to indexOfEraser as integer

setMN4Front()
tell application "System Events"
	tell process "MarginNote 4"
		-- 获取MN4所有窗口
		set windowList to windows
		
		if (count of windowList) is 0 then
			display dialog "没看到窗口,是不是你把它最小化了."
		else
			-- 如果窗口存在，获取最后一个窗口
			set targetWindow to item (count of windows) of windows
			
			-- 尝试查找屏幕上方工具栏
			try
				set buttonList to buttons of scroll area 1 of group 3 of group 3 of group 1 of group 1 of group 1 of group 1 of group 1 of targetWindow
			on error
				try
					set buttonList to buttons of scroll area 1 of group 4 of group 3 of group 1 of group 1 of group 1 of group 1 of group 1 of targetWindow
				on error
					try
						set buttonList to buttons of scroll area 1 of group 6 of group 3 of group 1 of group 1 of group 1 of group 1 of group 1 of targetWindow
					on error errMsg
						display dialog "不找了找不到的,你还在想些什么,这UI已经乱了,你就别再自找折磨" & errMsg
					end try
				end try
			end try
			
			-- 找到橡皮按钮并且触发点击事件
			set countOfButtons to count of buttonList
			if countOfButtons is 0 then
				display dialog "这工具栏是空的?"
			else
				-- 尝试使用配置文件中的值
				set buttonOfEraser to missing value
				try
					set buttonOfEraser to item indexOfEraser of buttonList
				on error
					-- 配置文件中的值无效，使用默认值
					try
						set buttonOfEraser to item defaultIndexOfEraser of buttonList
					on error
						display dialog "这也没找到橡皮擦按钮,请检查配置文件或默认值：" & plistFilePath
					end try
				end try
				
				if buttonOfEraser is not missing value then
					set eraserSelected to selected of buttonOfEraser
					if eraserSelected then
						--橡皮擦已经选中,则切换回第一根笔
						set buttonOfFirstPen to item 1 of buttonList
						try
							click buttonOfFirstPen
						on error
							display dialog "切换失败,请勿频繁点击!"
						end try
					else
						try
							click buttonOfEraser
						on error
							display dialog "切换失败,请勿频繁点击!"
						end try
					end if
				end if
			end if
		end if
	end tell
end tell