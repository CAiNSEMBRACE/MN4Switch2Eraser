-- 获取应用程序所在位置
set appPath to POSIX path of (path to me)
set appResourcesPath to appPath & "Contents/Resources/"

-- 定义存储文件路径
set plistFilePath to appResourcesPath & "MarginNote4EraserConfigMax.plist"

-- 定义默认值,原始情况下橡皮擦位于第四个工具位置
set defaultIndexOfEraser to 4
set defaultIndexOfLastButton to 1

-- 函数：读取配置文件并忽略注释行
on readPlistConfig(filePath)
	try
		tell application "System Events"
			set plistData to property list file filePath
			set indexOfEraser to value of property list item "indexOfEraser" of plistData
			set indexOfLastButton to value of property list item "indexOfLastButton" of plistData
			return {indexOfEraser, indexOfLastButton}
		end tell
	on error errMsg
		display dialog "读取配置文件时出错：" & errMsg
		return {defaultIndexOfEraser, defaultIndexOfLastButton}
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
set configValues to ""
try
	set configValues to readPlistConfig(plistFilePath)
	if configValues is {defaultIndexOfEraser, defaultIndexOfLastButton} then error "配置文件为空"
on error errMsg
	-- 配置文件不存在或无效，提示输入
	display dialog "配置文件读取失败：" & errMsg
	set userInput to display dialog "请输入橡皮擦按钮的序号（从1开始）：" default answer (defaultIndexOfEraser as string)
	set indexOfEraser to text returned of userInput as integer
	set indexOfLastButton to defaultIndexOfLastButton
	-- 将输入的橡皮擦编号和上一个按键默认值存储到配置文件
	set configContent to "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
<plist version=\"1.0\">
<dict>
	<key>indexOfEraser</key>
	<integer>" & indexOfEraser & "</integer>
	<key>indexOfLastButton</key>
	<integer>" & indexOfLastButton & "</integer>
</dict>
</plist>"
	try
		do shell script "echo " & quoted form of configContent & " > " & quoted form of plistFilePath
	on error writeErrMsg
		display dialog "无法写入配置文件：" & writeErrMsg
	end try
end try

-- 从配置文件读取的值
set indexOfEraser to item 1 of configValues
set indexOfLastButton to item 2 of configValues
setMN4Front()
tell application "System Events"
	tell process "MarginNote 4"
		-- 尝试获取所有窗口
		set windowList to windows
		
		if (count of windowList) is 0 then
			--如果窗口不存在,分支结束
			display dialog "未找到窗口信息,可能MarginNote 4已被隐藏."
		else
			-- 如果窗口存在，获取最后一个窗口
			set targetWindow to item (count of windows) of windows
			
			-- 尝试查找屏幕上方工具栏
			try
				set buttonList to buttons of scroll area 1 of group 3 of group 3 of group 1 of group 1 of group 1 of group 1 of group 1 of targetWindow
			on error
				-- 失败后尝试另一个可能的路径
				try
					set buttonList to buttons of scroll area 1 of group 4 of group 3 of group 1 of group 1 of group 1 of group 1 of group 1 of targetWindow
				on error
					-- 再次尝试
					try
						set buttonList to buttons of scroll area 1 of group 6 of group 3 of group 1 of group 1 of group 1 of group 1 of group 1 of targetWindow
					on error
						-- 无法一一列举,结束查找
						display dialog "不找了找不到的,你还在想些什么,这UI已经乱了,你就别再自找折磨"
					end try
				end try
			end try
			
			-- 找到橡皮按钮并且触发点击事件
			set countOfButtons to count of buttonList
			if countOfButtons is 0 then
				-- 基本不会出现这个情况,但是保留该分支
				display dialog "No buttons found of the MarginNote 4."
			else
				-- 尝试使用配置文件中的值
				set buttonOfEraser to missing value
				try
					set buttonOfEraser to item indexOfEraser of buttonList
				on error
					-- 配置文件中的橡皮擦序号值无效，使用默认值
					try
						set buttonOfEraser to item defaultIndexOfEraser of buttonList
					on error
						-- 当默认值也存在错误,结束并告知
						display dialog "无法找到橡皮擦按钮。请检查配置文件或默认值。"
					end try
				end try
				
				if buttonOfEraser is not missing value then
					set eraserSelected to selected of buttonOfEraser
					-- 判断按钮选中情况
					if eraserSelected then
						-- 如果橡皮按钮已经被选中,则无法获取上一个按钮的信息,则使用配置文件中的数据
						set buttonOfLastSelected to item indexOfLastButton of buttonList
						try
							click buttonOfLastSelected
						on error errMsg
							display dialog "切换失败,请勿频繁点击! :" & errMsg
						end try
					else
						-- 如果橡皮按钮未选中
						-- 则查找除橡皮擦以外被选中的按钮，并将其序号保存到配置文件
						set lastSelectedButtonFound to false
						repeat with i from 1 to countOfButtons
							if i is not indexOfEraser then
								set buttonOfLastSelected to item i of buttonList
								if selected of buttonOfLastSelected then
									set indexOfLastButton to i
									set lastSelectedButtonFound to true
									exit repeat
								end if
							end if
						end repeat
						
						-- 将找到的上一个按键信息存储到配置
						if not lastSelectedButtonFound then
							set indexOfLastButton to defaultIndexOfLastButton
						end if
						
						-- 点击橡皮擦
						try
							click buttonOfEraser
							-- 更新配置文件
							set configContent to "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
<plist version=\"1.0\">
<dict>
	<key>indexOfEraser</key>
	<integer>" & indexOfEraser & "</integer>
	<key>indexOfLastButton</key>
	<integer>" & indexOfLastButton & "</integer>
</dict>
</plist>"
							do shell script "echo " & quoted form of configContent & " > " & quoted form of plistFilePath
						on error
							display dialog "切换失败,请勿频繁点击!"
						end try
					end if
				end if
			end if
		end if
	end tell
end tell