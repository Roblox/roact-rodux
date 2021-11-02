-- upstream: https://github.com/facebook/react/blob/b61174fb7b09580c1ec2a8f55e73204b706d2935/packages/shared/ReactSymbols.js
--!strict
--[[*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file at https://github.com/facebook/react/blob/a774502e0ff2a82e3c0a3102534dbc3f1406e5ea/LICENSE
 *
 * @flow
 ]]

-- ATTENTION
-- When adding new symbols to this file,
-- Please consider also adding to 'react-devtools-shared/src/backend/ReactSymbols'

local exports = {
	-- The Symbol used to tag the ReactElement-like types. If there is no native Symbol
	-- nor polyfill, then a plain number is used for performance.
	REACT_ELEMENT_TYPE = 0xeac7,
	REACT_PORTAL_TYPE = 0xeaca,
	REACT_FRAGMENT_TYPE = 0xeacb,
	REACT_STRICT_MODE_TYPE = 0xeacc,
	REACT_PROFILER_TYPE = 0xead2,
	REACT_PROVIDER_TYPE = 0xeacd,
	REACT_CONTEXT_TYPE = 0xeace,
	REACT_FORWARD_REF_TYPE = 0xead0,
	REACT_SUSPENSE_TYPE = 0xead1,
	REACT_SUSPENSE_LIST_TYPE = 0xead8,
	REACT_MEMO_TYPE = 0xead3,
	REACT_LAZY_TYPE = 0xead4,
	REACT_SCOPE_TYPE = 0xead7,
	REACT_OPAQUE_ID_TYPE = 0xeae0,
	REACT_DEBUG_TRACING_MODE_TYPE = 0xeae1,
	REACT_OFFSCREEN_TYPE = 0xeae2,
	REACT_LEGACY_HIDDEN_TYPE = 0xeae3,
	REACT_BINDING_TYPE = 0xeae4,
}
