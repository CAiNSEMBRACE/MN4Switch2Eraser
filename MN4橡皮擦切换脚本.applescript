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

setMN4Front()
try
	tell application "System Events"
		tell process "MarginNote 4"
			set windowList to windows
			if (count of windowList) is 0 then
				display dialog "No windows found of the MarginNote 4."
			else
				set targetWindow to item (count of windows) of windows
				try
					set buttonList to buttons of scroll area 1 of group 3 of group 3 of group 1 of group 1 of group 1 of group 1 of group 1 of targetWindow
				end try
				set countOfButtons to count of buttonList
				if countOfButtons is 0 then
					display dialog "No buttons found of the MarginNote 4."
				else
					--注意,请将下面的数字4换成你的橡皮擦的编号
					--从1开始数,数到橡皮擦
					--例如:你的工具栏里是“钢笔、钢笔、彩笔、铅笔、橡皮”,就将下方的数字4换成5
					set indexOfEraser to 4
					set buttonOfEraser to item indexOfEraser of buttonList
					if selected of buttonOfEraser then
						set buttonOfFirstPen to item 1 of buttonList
						try
							click buttonOfFirstPen
						on error
							--display dialog "切换失败,请勿频繁点击!"
						end try
					else
						try
							click buttonOfEraser
						on error
							--display dialog "切换失败,请勿频繁点击!"
						end try
					end if
				end if
			end if
		end tell
	end tell
end try