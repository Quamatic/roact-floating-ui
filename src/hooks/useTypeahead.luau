local React = require(script.Parent.Parent.Parent.React)
local Timers = require(script.Parent.Parent.Parent.Timers)
local Array = require(script.Parent.Parent.Parent.Collections).Array

local useLatestRef = require(script.Parent.utils.useLatestRef)

type UseTypeaheadProps = {
	listRef: { current: { string | nil } },
	activeIndex: number?,
	onMatch: (index: number) -> ()?,
	onTypingChange: (isTyping: boolean) -> ()?,
	enabled: boolean?,
	findMatch: ((list: { string }, typedString: string) -> string?)?,
	resetMs: number?,
	ignoreKeys: { string },
	selectedIndex: number?,
}

--[=[
	@within Hooks
]=]
local function useTypeahead(context, props: UseTypeaheadProps)
	local open = context.open

	local activeIndex = props.activeIndex
	local unstable_onMatch = props.onMatch
	local unstable_onTypingChange = props.onTypingChange
	local enabled = props.enabled or true
	local findMatch = props.findMatch
	local resetMs = props.resetMs or 750
	local ignoreKeys = props.ignoreKeys or {}
	local selectedIndex = props.selectedIndex

	local timeoutIdRef = React.useRef(nil)
	local matchIndexRef = React.useRef(nil)
	local stringRef = React.useRef("")
	local prevIndexRef = React.useRef(nil)

	local findMatchRef = useLatestRef(findMatch)
	local ignoreKeysRef = useLatestRef(ignoreKeys)

	React.useLayoutEffect(function()
		if open then
			Timers.clearTimeout(timeoutIdRef.current)
			matchIndexRef.current = nil
			stringRef.current = ""
		end
	end, { open })

	React.useLayoutEffect(function()
		if open and stringRef.current == "" then
			prevIndexRef.current = selectedIndex or activeIndex or -1
		end
	end, { open, selectedIndex, activeIndex })

	return React.useMemo(function()
		if not enabled then
			return {}
		end

		local function setTypingChange(value: boolean) end

		local function getMatchingIndex(list: { string }, orderedList: { string }, string: string)
			local str = if findMatchRef.current
				then findMatchRef.current(orderedList, string)
				else Array.find(orderedList, function(text) end)

			return if str and str ~= -1 then Array.indexOf(list, str) else -1
		end

		local function onKeyDown(input: InputObject) end

		return {
			reference = {},
			floating = {
				[React.Event.InputBegan] = onKeyDown,
				[React.Event.InputEnded] = function(input: InputObject)
					if input.KeyCode == Enum.KeyCode.Space then
						setTypingChange(false)
					end
				end,
			},
		}
	end, { enabled })
end

return useTypeahead
