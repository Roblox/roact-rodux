return function()
	local Roact = require(script.Parent.Parent.Roact)
	local getComponentName = require(script.Parent.getComponentName)
	local ReactSymbols = require(script.Parent.ReactSymbols)

	describe("function components", function()
		local function MyComponent() end
		local anonymous = function() end

		it("gets name from non-anonymous function", function()
			expect(getComponentName(MyComponent)).to.equal("MyComponent")
		end)
		it("gets nil from anonymous function", function()
			local anonymous = function() end
			expect(getComponentName(anonymous)).to.equal(nil)
		end)
	end)

	describe("class components", function()
		local MyClassComponent = Roact.Component:extend("MyClassComponent")

		it("gets name from non-anonymous function", function()
			expect(getComponentName(MyClassComponent)).to.equal("MyClassComponent")
		end)
		it("gets nil from unnamed component", function()
			local unnamed = Roact.Component:extend("")
			expect(getComponentName(unnamed)).to.equal(nil)
		end)
	end)

	describe("React symbols", function()
		it("fragment", function()
			expect(getComponentName(ReactSymbols.REACT_FRAGMENT_TYPE)).to.equal("Fragment")
		end)
		it("Context without displayName", function()
			local ContextComponent = {
				["$$typeof"] = ReactSymbols.REACT_CONTEXT_TYPE,
			}
			expect(getComponentName(ContextComponent)).to.equal("Context.Consumer")
		end)
		it("Context with displayName", function()
			local ContextComponent = {
				["$$typeof"] = ReactSymbols.REACT_CONTEXT_TYPE,
				displayName = "MyContext",
			}
			expect(getComponentName(ContextComponent)).to.equal("MyContext.Consumer")
		end)
		it("forward ref", function()
			local function InnerComponent() end
			local ForwardRefComponent = {
				["$$typeof"] = ReactSymbols.REACT_FORWARD_REF_TYPE,
				displayName = "MyForwardRef",
				render = InnerComponent,
			}
			expect(getComponentName(ForwardRefComponent)).to.equal("ForwardRef(InnerComponent)")
		end)
	end)

	describe("random tables", function()
		local odd = newproxy(true)

		getmetatable(odd).__tostring = function()
			return "random table"
		end

		it("gets name from table with __tostring overriden", function()
			expect(getComponentName(odd)).to.equal("random table")
		end)
	end)
end
