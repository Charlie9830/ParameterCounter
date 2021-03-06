-- ===================== --
-- ParameterCounter
-- ===================== --
-- Version 1.0
-- Created by Charlie Hall
-- https://www.github.com/charlie9830
-- Last Updated April 2021
--
-- Source Code available at:
-- https://github.com/Charlie9830/ParameterCounter
--
--
-- DESCRIPTION --
-- =========== --
-- This plugin will collate the parameter count of only the universes that have been "Requested" in the DMX Universe Pool.
-- 
--
-- IMPORTANT --
-- ========= --
-- Due to how MA calculates parameters for FixtureTypes with 'Virtual Channels', this plugin cannot correctly count parameters
-- for FixtureTypes with 'Virtual Channels'. If you have a number of FixtureTypes with 'Virtual Channels' the parameter count
-- reported by this plugin will be LESS then what the actual parameter count is.
-- LICENSES --
-- ======== --
-- ParameterCounter
-- MIT License
-- Copyright (c) 2021 Charlie Hall
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.
-- CONFIG
local MAX_UNIVERSE = 128;

-- PROGRESS HANDLES
local universeRequestProgessHandle
local paramCountProgressHandle

local function getRequestedUniverses(progressHandle)
    local requestedUniverses = {};
    gma.gui.progress.setrange(progressHandle, 1, MAX_UNIVERSE);
    for universeIndex = 1, MAX_UNIVERSE do
        local handle = gma.show.getobj.handle("DMXUniverse " .. universeIndex);
        local requested = gma.show.property.get(handle, "Requested");

        if requested == "On" then
            requestedUniverses[#requestedUniverses + 1] = universeIndex;
        end

        if (math.fmod(universeIndex, 10) == 0) then
            gma.gui.progress.set(progressHandle, universeIndex)
        end
    end

    return requestedUniverses
end

local function calculateParams(universeNumber)
    local paramCount = 0;
    for addr = 1, 512 do
        local handle = gma.show.getobj.handle("DMX " .. universeNumber .. '.' .. addr);
        local fixId = gma.show.property.get(handle, "FixId");
        local chaId = gma.show.property.get(handle, "ChaId");
        local type = gma.show.property.get(handle, "Type");

        if type == "Coarse" then
            if fixId ~= "" or chaId ~= "" then
                paramCount = paramCount + 1
            end
        end

    end

    return paramCount;
end

local function Main()
    universeRequestProgessHandle = gma.gui.progress.start("Collecting Requested Universes");
    local requestedUniverses = getRequestedUniverses(universeRequestProgessHandle);
    gma.gui.progress.stop(universeRequestProgessHandle);

    local totalParamCount = 0;

    paramCountProgressHandle = gma.gui.progress.start("Counting Parameters");
    gma.gui.progress.setrange(paramCountProgressHandle, 1, #requestedUniverses);
    local progressCount = 1;
    for _, uniNumber in ipairs(requestedUniverses) do
        totalParamCount = totalParamCount + calculateParams(uniNumber);
        gma.gui.progress.set(paramCountProgressHandle, progressCount);
        progressCount = progressCount + 1;
    end

    gma.gui.progress.stop(paramCountProgressHandle);

    gma.gui.msgbox('Done',
        'Counted ' .. totalParamCount .. ' parameters across ' .. #requestedUniverses .. ' requested Universes. \n \n' ..
            [[  -- REMINDER --
                This plugin cannot account for Virtual Channels within fixtures,
        totals may not be 100% correct when counting fixtures with Virtual Channels,
        Consult the Fixture Types menu to determine if you have a case of Virtual Channel fixtures.]]);
end

local function Cleanup()
    gma.gui.progress.stop(universeRequestProgessHandle);
    gma.gui.progress.stop(paramCountProgressHandle);
end

return Main, Cleanup
