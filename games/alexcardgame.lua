local b334c = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
local r334c = function(i, f)
return function()
local c = f()
b334c[i] = function() return c end
return c
end
end
local function m334c()
local function __TS__New(target, ...)
local instance = setmetatable({}, target.prototype)
instance:____constructor(...)
return instance
end
local __TS__Symbol, Symbol
do
local symbolMetatable = {__tostring = function(self)
return ("Symbol(" .. (self.description or "")) .. ")"
end}
function __TS__Symbol(description)
return setmetatable({description = description}, symbolMetatable)
end
Symbol = {
asyncDispose = __TS__Symbol("Symbol.asyncDispose"),
dispose = __TS__Symbol("Symbol.dispose"),
iterator = __TS__Symbol("Symbol.iterator"),
hasInstance = __TS__Symbol("Symbol.hasInstance"),
species = __TS__Symbol("Symbol.species"),
toStringTag = __TS__Symbol("Symbol.toStringTag")
}
end
local function __TS__InstanceOf(obj, classTbl)
if type(classTbl) ~= "table" then
error("Right-hand side of 'instanceof' is not an object", 0)
end
if classTbl[Symbol.hasInstance] ~= nil then
return not not classTbl[Symbol.hasInstance](classTbl, obj)
end
if type(obj) == "table" then
local luaClass = obj.constructor
while luaClass ~= nil do
if luaClass == classTbl then
return true
end
luaClass = luaClass.____super
end
end
return false
end
local function __TS__Class(self)
local c = {prototype = {}}
c.prototype.__index = c.prototype
c.prototype.constructor = c
return c
end
local __TS__Promise
do
local function makeDeferredPromiseFactory()
local resolve
local reject
local function executor(____, res, rej)
resolve = res
reject = rej
end
return function()
local promise = __TS__New(__TS__Promise, executor)
return promise, resolve, reject
end
end
local makeDeferredPromise = makeDeferredPromiseFactory()
local function isPromiseLike(value)
return __TS__InstanceOf(value, __TS__Promise)
end
local function doNothing(self)
end
local ____pcall = _G.pcall
__TS__Promise = __TS__Class()
__TS__Promise.name = "__TS__Promise"
function __TS__Promise.prototype.____constructor(self, executor)
self.state = 0
self.fulfilledCallbacks = {}
self.rejectedCallbacks = {}
self.finallyCallbacks = {}
local success, ____error = ____pcall(
executor,
nil,
function(____, v) return self:resolve(v) end,
function(____, err) return self:reject(err) end
)
if not success then
self:reject(____error)
end
end
function __TS__Promise.resolve(value)
if __TS__InstanceOf(value, __TS__Promise) then
return value
end
local promise = __TS__New(__TS__Promise, doNothing)
promise.state = 1
promise.value = value
return promise
end
function __TS__Promise.reject(reason)
local promise = __TS__New(__TS__Promise, doNothing)
promise.state = 2
promise.rejectionReason = reason
return promise
end
__TS__Promise.prototype["then"] = function(self, onFulfilled, onRejected)
local promise, resolve, reject = makeDeferredPromise()
self:addCallbacks(
onFulfilled and self:createPromiseResolvingCallback(onFulfilled, resolve, reject) or resolve,
onRejected and self:createPromiseResolvingCallback(onRejected, resolve, reject) or reject
)
return promise
end
function __TS__Promise.prototype.addCallbacks(self, fulfilledCallback, rejectedCallback)
if self.state == 1 then
return fulfilledCallback(nil, self.value)
end
if self.state == 2 then
return rejectedCallback(nil, self.rejectionReason)
end
local ____self_fulfilledCallbacks_0 = self.fulfilledCallbacks
____self_fulfilledCallbacks_0[#____self_fulfilledCallbacks_0 + 1] = fulfilledCallback
local ____self_rejectedCallbacks_1 = self.rejectedCallbacks
____self_rejectedCallbacks_1[#____self_rejectedCallbacks_1 + 1] = rejectedCallback
end
function __TS__Promise.prototype.catch(self, onRejected)
return self["then"](self, nil, onRejected)
end
function __TS__Promise.prototype.finally(self, onFinally)
if onFinally then
local ____self_finallyCallbacks_2 = self.finallyCallbacks
____self_finallyCallbacks_2[#____self_finallyCallbacks_2 + 1] = onFinally
if self.state ~= 0 then
onFinally(nil)
end
end
return self
end
function __TS__Promise.prototype.resolve(self, value)
if isPromiseLike(value) then
return value:addCallbacks(
function(____, v) return self:resolve(v) end,
function(____, err) return self:reject(err) end
)
end
if self.state == 0 then
self.state = 1
self.value = value
return self:invokeCallbacks(self.fulfilledCallbacks, value)
end
end
function __TS__Promise.prototype.reject(self, reason)
if self.state == 0 then
self.state = 2
self.rejectionReason = reason
return self:invokeCallbacks(self.rejectedCallbacks, reason)
end
end
function __TS__Promise.prototype.invokeCallbacks(self, callbacks, value)
local callbacksLength = #callbacks
local finallyCallbacks = self.finallyCallbacks
local finallyCallbacksLength = #finallyCallbacks
if callbacksLength ~= 0 then
for i = 1, callbacksLength - 1 do
callbacks[i](callbacks, value)
end
if finallyCallbacksLength == 0 then
return callbacks[callbacksLength](callbacks, value)
end
callbacks[callbacksLength](callbacks, value)
end
if finallyCallbacksLength ~= 0 then
for i = 1, finallyCallbacksLength - 1 do
finallyCallbacks[i](finallyCallbacks)
end
return finallyCallbacks[finallyCallbacksLength](finallyCallbacks)
end
end
function __TS__Promise.prototype.createPromiseResolvingCallback(self, f, resolve, reject)
return function(____, value)
local success, resultOrError = ____pcall(f, nil, value)
if not success then
return reject(nil, resultOrError)
end
return self:handleCallbackValue(resultOrError, resolve, reject)
end
end
function __TS__Promise.prototype.handleCallbackValue(self, value, resolve, reject)
if isPromiseLike(value) then
local nextpromise = value
if nextpromise.state == 1 then
return resolve(nil, nextpromise.value)
elseif nextpromise.state == 2 then
return reject(nil, nextpromise.rejectionReason)
else
return nextpromise:addCallbacks(resolve, reject)
end
else
return resolve(nil, value)
end
end
end
local __TS__AsyncAwaiter, __TS__Await
do
local ____coroutine = _G.coroutine or ({})
local cocreate = ____coroutine.create
local coresume = ____coroutine.resume
local costatus = ____coroutine.status
local coyield = ____coroutine.yield
function __TS__AsyncAwaiter(generator)
return __TS__New(
__TS__Promise,
function(____, resolve, reject)
local fulfilled, step, resolved, asyncCoroutine
function fulfilled(self, value)
local success, resultOrError = coresume(asyncCoroutine, value)
if success then
return step(resultOrError)
end
return reject(nil, resultOrError)
end
function step(result)
if resolved then
return
end
if costatus(asyncCoroutine) == "dead" then
return resolve(nil, result)
end
return __TS__Promise.resolve(result):addCallbacks(fulfilled, reject)
end
resolved = false
asyncCoroutine = cocreate(generator)
local success, resultOrError = coresume(
asyncCoroutine,
function(____, v)
resolved = true
return __TS__Promise.resolve(v):addCallbacks(resolve, reject)
end
)
if success then
return step(resultOrError)
else
return reject(nil, resultOrError)
end
end
)
end
function __TS__Await(thing)
return coyield(thing)
end
end
local function __TS__ArrayMap(self, callbackfn, thisArg)
local result = {}
for i = 1, #self do
result[i] = callbackfn(thisArg, self[i], i - 1, self)
end
return result
end
local ____exports = {}
local ____gameUI = b334c[1]('game_src_ui_gameUI')
local printCurrentGameState = ____gameUI.printCurrentGameState
local printOpponentPoints = ____gameUI.printOpponentPoints
local printPlayerPoints = ____gameUI.printPlayerPoints
local printControls = ____gameUI.printControls
local printUpgradeInfo = ____gameUI.printUpgradeInfo
local ____GameManager = b334c[2]('game_src_game_managers_GameManager')
local GameManager = ____GameManager.GameManager
local ____GameConfig = b334c[3]('game_src_game_config_GameConfig')
local GameConfig = ____GameConfig.GameConfig
do
local ____assets = b334c[4]('game_src_assets')
____exports.assets = ____assets.assets
end
local gameManager
local pressed = false
local doOnce = false
____exports.meta = {title = "Card Game", author = "", version = "1.0.0", description = ""}
local function init(_, std)
print("Initializing game...")
gameManager = __TS__New(GameManager, std)
end
local function loop(_, std)
return __TS__AsyncAwaiter(function(____awaiter_resolve)
if std.key.press.any then
pressed = true
else
pressed = false
end
gameManager:update(std.delta)
end)
end
local function draw(_, std)
std.image.draw("https://raw.githubusercontent.com/AlexOliveiraaDev/cardgame-glyengine/refs/heads/main/src/game/assets/bg.png", 0, 0)
std.draw.color(std.color.white)
std.text.font_size(GameConfig.UI_FONT_SIZE_SMALL)
std.text.font_name(GameConfig.UI_FONT_NAME)
printCurrentGameState(
std,
gameManager:getGameStateText()
)
printPlayerPoints(
std,
gameManager:getPlayer()
)
printOpponentPoints(
std,
gameManager:getOpponent()
)
gameManager:render()
local playerUpgrades = gameManager:getPlayer():getUpgrades()
if #playerUpgrades > 0 then
printUpgradeInfo(std, playerUpgrades)
end
printControls(std)
if GameConfig.DEBUG_MODE then
std.text.font_size(GameConfig.UI_FONT_SIZE_TINY)
std.text.print(
10,
10,
"State: " .. gameManager:getGameState()
)
std.text.print(
10,
25,
"Player Cards: " .. tostring(#gameManager:getPlayer():getHandCards())
)
std.text.print(
10,
40,
"Player Points: " .. tostring(gameManager:getPlayer():getMatchPoints())
)
std.text.print(
10,
55,
"Opponent Points: " .. tostring(gameManager:getOpponent():getMatchPoints())
)
if GameConfig.SHOW_OPPONENT_CARDS then
local opponentCards = gameManager:getOpponent().hand:getAllCards()
std.text.print(
10,
70,
"Opponent Cards: " .. table.concat(
__TS__ArrayMap(
opponentCards,
function(____, c) return c.name end
),
", "
)
)
end
end
end
local function key(_, std)
if pressed then
return
end
local keyString = ""
if std.key.press.left then
keyString = "left"
elseif std.key.press.right then
keyString = "right"
elseif std.key.press.up then
keyString = "up"
elseif std.key.press.down then
keyString = "down"
elseif std.key.press.a then
keyString = "action"
elseif std.key.press.menu then
keyString = "menu"
end
if keyString then
gameManager:handleInput(keyString)
end
end
local function exit(_, std)
print("Game exiting...")
end
____exports.config = {require = "http media.video"}
____exports.callbacks = {
init = init,
loop = loop,
draw = draw,
exit = exit,
key = key
}
return ____exports
end
b334c[1] = r334c(1, function()
local function __TS__ArrayForEach(self, callbackFn, thisArg)
for i = 1, #self do
callbackFn(thisArg, self[i], i - 1, self)
end
end
local ____exports = {}
function ____exports.printCurrentGameState(std, gameStateText)
local x = std.app.width / 2 - #gameStateText * 4
local y = 50
std.draw.color(std.color.white)
std.text.font_size(18)
std.text.print(x, y, gameStateText)
end
function ____exports.printPlayerPoints(std, player)
local text = ("Player: " .. tostring(player:getMatchPoints())) .. " pontos"
local x = 20
local y = std.app.height - 80
std.draw.color(6553779)
std.draw.rect(
0,
x - 5,
y - 5,
#text * 7 + 10,
20
)
std.draw.color(std.color.white)
std.text.font_size(12)
std.text.print(x, y, text)
local cardsText = "Cartas: " .. tostring(#player:getHandCards())
std.text.print(x, y + 25, cardsText)
end
function ____exports.printOpponentPoints(std, opponent)
local text = ("Opponent: " .. tostring(opponent.matchPoints)) .. " pontos"
local x = std.app.width - #text * 7 - 20
local y = std.app.height - 80
std.draw.color(0x640000B3)
std.draw.rect(
0,
x - 5,
y - 5,
#text * 7 + 10,
20
)
std.draw.color(std.color.white)
std.text.font_size(12)
std.text.print(x, y, text)
local cardsText = "Cartas: " .. tostring(#opponent.hand:getAllCards())
std.text.print(x, y + 25, cardsText)
end
function ____exports.printUpgradeInfo(std, upgrades)
if #upgrades == 0 then
return
end
local x = 20
local y = 100
std.draw.color(0xFFFFFFFF)
std.text.font_size(14)
std.text.print(x, y, "Upgrades Ativos:")
__TS__ArrayForEach(
upgrades,
function(____, upgrade, index)
local upgradeY = y + 20 + index * 15
std.text.font_size(10)
std.text.print(
x + 10,
upgradeY,
"• " .. tostring(upgrade.name)
)
end
)
end
function ____exports.printControls(std)
local controls = {"← → : Navegar", "Z/Enter : Selecionar"}
local x = std.app.width - 150
local y = 20
std.draw.color(204)
std.draw.rect(
0,
x - 10,
y - 5,
160,
#controls * 15 + 10
)
std.draw.color(std.color.white)
std.text.font_size(10)
__TS__ArrayForEach(
controls,
function(____, control, index)
std.text.print(x, y + index * 15, control)
end
)
end
function ____exports.printCardInfo(std, card, x, y)
if not card then
return
end
local info = {
"Nome: " .. tostring(card.name),
"Valor: " .. tostring(card.value),
card.is_special and "Especial: Sim" or "Especial: Não"
}
std.draw.color(std.color.white)
std.draw.rect(
0,
x - 5,
y - 5,
120,
#info * 12 + 10
)
std.draw.color(0xFFFFFFFF)
std.text.font_size(9)
__TS__ArrayForEach(
info,
function(____, text, index)
std.text.print(x, y + index * 12, text)
end
)
end
return ____exports
end)
b334c[2] = r334c(2, function()
local function __TS__Class(self)
local c = {prototype = {}}
c.prototype.__index = c.prototype
c.prototype.constructor = c
return c
end
local function __TS__New(target, ...)
local instance = setmetatable({}, target.prototype)
instance:____constructor(...)
return instance
end
local __TS__StringSplit
do
local sub = string.sub
local find = string.find
function __TS__StringSplit(source, separator, limit)
if limit == nil then
limit = 4294967295
end
if limit == 0 then
return {}
end
local result = {}
local resultIndex = 1
if separator == nil or separator == "" then
for i = 1, #source do
result[resultIndex] = sub(source, i, i)
resultIndex = resultIndex + 1
end
else
local currentPos = 1
while resultIndex <= limit do
local startPos, endPos = find(source, separator, currentPos, true)
if not startPos then
break
end
result[resultIndex] = sub(source, currentPos, startPos - 1)
resultIndex = resultIndex + 1
currentPos = endPos + 1
end
if resultIndex <= limit then
result[resultIndex] = sub(source, currentPos)
end
end
return result
end
end
local ____exports = {}
local ____table = b334c[5]('game_src_game_entities_table')
local Table = ____table.Table
local ____Player = b334c[6]('game_src_game_entities_Player')
local Player = ____Player.Player
local ____Opponent = b334c[7]('game_src_game_entities_Opponent')
local Opponent = ____Opponent.Opponent
local ____UpgradeManager = b334c[8]('game_src_game_upgrades_UpgradeManager')
local UpgradeManager = ____UpgradeManager.UpgradeManager
local ____waitManager = b334c[9]('game_src_core_utils_waitManager')
local WaitManager = ____waitManager.WaitManager
local ____CardDefinitions = b334c[10]('game_src_game_data_CardDefinitions')
local CARD_LIST = ____CardDefinitions.CARD_LIST
local ____GameConfig = b334c[3]('game_src_game_config_GameConfig')
local GameConfig = ____GameConfig.GameConfig
local ____menuManager = b334c[11]('game_src_game_managers_menuManager')
local MenuManager = ____menuManager.MenuManager
____exports.GameState = ____exports.GameState or ({})
____exports.GameState.MENU = "MENU"
____exports.GameState.WAITING_PLAYER_INPUT = "WAITING_PLAYER_INPUT"
____exports.GameState.PLAYER_TURN_ANIMATION = "PLAYER_TURN_ANIMATION"
____exports.GameState.WAITING_ENEMY_TURN = "WAITING_ENEMY_TURN"
____exports.GameState.ENEMY_TURN_ANIMATION = "ENEMY_TURN_ANIMATION"
____exports.GameState.CALCULATING_RESULTS = "CALCULATING_RESULTS"
____exports.GameState.CHOOSING_UPGRADE = "CHOOSING_UPGRADE"
____exports.GameState.GAME_OVER = "GAME_OVER"
____exports.TurnType = ____exports.TurnType or ({})
____exports.TurnType.PLAYER_FIRST = "PLAYER_FIRST"
____exports.TurnType.OPPONENT_FIRST = "OPPONENT_FIRST"
____exports.GameManager = __TS__Class()
local GameManager = ____exports.GameManager
GameManager.name = "GameManager"
function GameManager.prototype.____constructor(self, std)
self.currentTurn = ____exports.TurnType.PLAYER_FIRST
self.roundNumber = 1
self.firstPlayerCard = nil
self.isWaitingForSecondPlayer = false
self.gameState = ____exports.GameState.WAITING_PLAYER_INPUT
self.gameStateText = "Escolha sua carta"
self.std = std
self.waitManager = __TS__New(WaitManager)
self.menuManager = __TS__New(MenuManager, std)
self:initializeGame()
self.gameState = ____exports.GameState.MENU
self.gameStateText = "Menu Principal"
end
function GameManager.prototype.initializeGame(self)
print("Initializing game from menu...")
self.player = __TS__New(Player)
self.opponent = __TS__New(Opponent, GameConfig.DEFAULT_OPPONENT_DUMBNESS)
self.table = __TS__New(Table, self.std)
self.upgradeManager = __TS__New(UpgradeManager, self.player)
end
function GameManager.prototype.cleanTable(self)
self.table:cleanTable()
end
function GameManager.prototype.handleOpponentTurn(self)
if self.gameState ~= ____exports.GameState.WAITING_ENEMY_TURN then
return
end
self.gameState = ____exports.GameState.ENEMY_TURN_ANIMATION
self.waitManager:addWait({
id = "opponent_thinking",
duration = GameConfig.OPPONENT_THINKING_TIME,
onComplete = function()
local opponentSelectedCard = self.opponent:getBestCard(self.table:getPlayerCard())
print("Oponente jogou: " .. opponentSelectedCard.name)
self.table:setOpponentCard(opponentSelectedCard)
self.waitManager:addWait({
id = "opponent_card_animation",
duration = GameConfig.CARD_ANIMATION_DURATION,
onComplete = function()
self:handleGameCalculation()
end
})
end,
onUpdate = function(____, progress)
end
})
end
function GameManager.prototype.handleGameCalculation(self)
self.gameState = ____exports.GameState.CALCULATING_RESULTS
self.gameStateText = "Calculando resultado..."
local playerCard = self.table:getPlayerCard()
local opponentCard = self.table:getOpponentCard()
local playerValue = self:calculateCardValue(playerCard, self.player)
local opponentValue = opponentCard.value
local playerAttacked = self.currentTurn == ____exports.TurnType.PLAYER_FIRST
local ____playerAttacked_0
if playerAttacked then
____playerAttacked_0 = playerValue
else
____playerAttacked_0 = opponentValue
end
local attackerValue = ____playerAttacked_0
local ____playerAttacked_1
if playerAttacked then
____playerAttacked_1 = opponentValue
else
____playerAttacked_1 = playerValue
end
local defenderValue = ____playerAttacked_1
print("Rodada " .. tostring(self.roundNumber))
print(((playerAttacked and "Jogador" or "Oponente") .. " atacou: ") .. tostring(attackerValue))
print(((playerAttacked and "Oponente" or "Jogador") .. " revidou: ") .. tostring(defenderValue))
self.waitManager:addWait({
id = "calculating_results",
duration = GameConfig.RESULT_CALCULATION_TIME,
onComplete = function()
if playerValue > opponentValue then
local ____self_player_2, ____matchPoints_3 = self.player, "matchPoints"
____self_player_2[____matchPoints_3] = ____self_player_2[____matchPoints_3] + 1
self.table:hitOpponent()
self.gameStateText = "Jogador ganhou a rodada!"
elseif opponentValue > playerValue then
local ____self_opponent_4, ____matchPoints_5 = self.opponent, "matchPoints"
____self_opponent_4[____matchPoints_5] = ____self_opponent_4[____matchPoints_5] + 1
self.table:hitPlayer()
self.gameStateText = "Oponente ganhou a rodada!"
else
self.gameStateText = "Empate!"
end
if #self.player:getHandCards() == 0 then
self:handleEndGame()
else
self:alternateFirstPlayer()
self.waitManager:addWait({
id = "finish_round",
duration = 1,
onComplete = function()
self:cleanTable()
self:startNewRound()
end
})
end
end,
onUpdate = function(____, progress)
print(("Calculando resultado: " .. tostring(math.floor(progress * 100 + 0.5))) .. "%")
end
})
end
function GameManager.prototype.alternateFirstPlayer(self)
self.currentTurn = self.currentTurn == ____exports.TurnType.PLAYER_FIRST and ____exports.TurnType.OPPONENT_FIRST or ____exports.TurnType.PLAYER_FIRST
self.roundNumber = self.roundNumber + 1
print(((("Próxima rodada (" .. tostring(self.roundNumber)) .. "): ") .. (self.currentTurn == ____exports.TurnType.PLAYER_FIRST and "Jogador" or "Oponente")) .. " começa")
end
function GameManager.prototype.startNewRound(self)
self.firstPlayerCard = nil
if self.currentTurn == ____exports.TurnType.PLAYER_FIRST then
self.gameState = ____exports.GameState.WAITING_PLAYER_INPUT
self.gameStateText = "Sua vez de atacar!"
else
self.gameState = ____exports.GameState.WAITING_ENEMY_TURN
self.gameStateText = "Oponente vai atacar primeiro..."
self.waitManager:addWait({
id = "opponent_first_delay",
duration = 0.5,
onComplete = function()
self:handleOpponentFirstMove()
end
})
end
end
function GameManager.prototype.calculateCardValue(self, card, player)
local value = card.value
local upgrades = player:getUpgrades()
for ____, upgrade in ipairs(upgrades) do
end
value = self:applyComboNaipes(
player:getCardHistory(),
value
)
return value
end
function GameManager.prototype.applyComboNaipes(self, cardHistory, value)
if #cardHistory < 3 then
return value
end
local cardType = __TS__StringSplit(cardHistory[1].id, "_")[1]
local count = 0
do
local i = 0
while i < math.min(#cardHistory, 3) do
local card = cardHistory[i + 1]
if __TS__StringSplit(card.id, "_")[1] == cardType then
count = count + 1
end
i = i + 1
end
end
if count >= 3 then
print("aplicando dobro do valor")
return value * 2
end
return value
end
function GameManager.prototype.handleEndGame(self)
if self.player:getMatchPoints() > self.opponent.matchPoints then
print("Jogador ganhou a partida!")
self.gameState = ____exports.GameState.CHOOSING_UPGRADE
self.gameStateText = "Escolha um upgrade!"
self.upgradeManager:setCardsCenterPosition(self.std.app.width, self.std.app.height)
else
print("Jogador perdeu a partida!")
self.gameState = ____exports.GameState.GAME_OVER
self.gameStateText = "Game Over"
end
end
function GameManager.prototype.handleUpgradeSelection(self)
local selectedUpgrade = self.upgradeManager:getSelectedUpgrade()
self.player:addUpgrade(selectedUpgrade)
print("Upgrade selecionado: " .. selectedUpgrade.name)
self:resetGame()
self.gameState = ____exports.GameState.WAITING_PLAYER_INPUT
self.gameStateText = "Escolha sua carta"
end
function GameManager.prototype.handleInput(self, key)
if self.gameState == ____exports.GameState.MENU then
local handled = self.menuManager:handleInput(key)
if self.menuManager:isInGame() then
self:initializeGame()
self.gameState = ____exports.GameState.CHOOSING_UPGRADE
self.upgradeManager:setCardsCenterPosition(self.std.app.width, self.std.app.height)
self.gameStateText = "Escolha seu primeiro upgrade!"
end
return
end
if self.gameState == ____exports.GameState.GAME_OVER then
if key == "menu" or key == "action" then
self.menuManager:returnToMenu()
self.gameState = ____exports.GameState.MENU
return
end
return
end
if self.gameState == ____exports.GameState.WAITING_PLAYER_INPUT then
repeat
local ____switch43 = key
local ____cond43 = ____switch43 == "left"
if ____cond43 then
self.player.hand:switchActiveCard(false)
break
end
____cond43 = ____cond43 or ____switch43 == "right"
if ____cond43 then
self.player.hand:switchActiveCard(true)
break
end
____cond43 = ____cond43 or ____switch43 == "action"
if ____cond43 then
if self.currentTurn == ____exports.TurnType.PLAYER_FIRST then
self:handlePlayerCardSelection()
else
self:handlePlayerResponse()
end
break
end
until true
end
if self.gameState == ____exports.GameState.CHOOSING_UPGRADE then
repeat
local ____switch47 = key
local ____cond47 = ____switch47 == "left"
if ____cond47 then
self.upgradeManager:switchActiveCard(false)
break
end
____cond47 = ____cond47 or ____switch47 == "right"
if ____cond47 then
self.upgradeManager:switchActiveCard(true)
break
end
____cond47 = ____cond47 or ____switch47 == "action"
if ____cond47 then
self:handleUpgradeSelection()
break
end
until true
end
end
function GameManager.prototype.resetGame(self)
print("reseting game")
self.currentTurn = ____exports.TurnType.PLAYER_FIRST
self.roundNumber = 1
self.firstPlayerCard = nil
self.player.matchPoints = 0
self.opponent.matchPoints = 0
self.player.hand:generateNewHand(CARD_LIST)
self.opponent:generateNewHand(CARD_LIST)
self.player.hand:setCardsPosition(self.std.app.width, self.std.app.height)
self.opponent:setCardsPosition(self.std.app.width, self.std.app.height)
if #self.player.hand:getAllCards() > 0 then
self.player.hand:getAllCards()[1]:up()
end
self.table.lastPlayerCard = nil
self.table.lastOpponentCard = nil
end
function GameManager.prototype.getCurrentTurnInfo(self)
return {turn = self.currentTurn, round = self.roundNumber}
end
function GameManager.prototype.handlePlayerCardSelection(self)
if self.gameState ~= ____exports.GameState.WAITING_PLAYER_INPUT then
return
end
if self.currentTurn ~= ____exports.TurnType.PLAYER_FIRST then
return
end
local selectedCard = self.player:getSelectedCard()
self.table:setPlayerCard(selectedCard)
self.firstPlayerCard = selectedCard
self.gameState = ____exports.GameState.PLAYER_TURN_ANIMATION
self.gameStateText = "Jogador atacou! Oponente vai revidar..."
self.waitManager:addWait({
id = "player_card_animation",
duration = GameConfig.CARD_ANIMATION_DURATION,
onComplete = function()
self.gameState = ____exports.GameState.WAITING_ENEMY_TURN
self.gameStateText = "Oponente revidando..."
self:handleOpponentResponse()
end,
onUpdate = function(____, progress)
end
})
end
function GameManager.prototype.handleOpponentFirstMove(self)
if self.gameState ~= ____exports.GameState.WAITING_ENEMY_TURN then
return
end
self.gameState = ____exports.GameState.ENEMY_TURN_ANIMATION
self.gameStateText = "Oponente atacando..."
self.waitManager:addWait({
id = "opponent_thinking",
duration = GameConfig.OPPONENT_THINKING_TIME,
onComplete = function()
local opponentCards = self.opponent.hand:getAllCards()
local randomCard = opponentCards[math.floor(math.random() * #opponentCards) + 1]
print("Oponente atacou com: " .. randomCard.name)
self.opponent:removeSelectedCard(randomCard)
self.table:setOpponentCard(randomCard)
self.firstPlayerCard = randomCard
self.waitManager:addWait({
id = "opponent_card_animation",
duration = GameConfig.CARD_ANIMATION_DURATION,
onComplete = function()
self.gameState = ____exports.GameState.WAITING_PLAYER_INPUT
self.gameStateText = "Oponente atacou! Sua vez de revidar!"
end
})
end,
onUpdate = function(____, progress)
end
})
end
function GameManager.prototype.handleOpponentResponse(self)
if self.gameState ~= ____exports.GameState.WAITING_ENEMY_TURN then
return
end
self.gameState = ____exports.GameState.ENEMY_TURN_ANIMATION
self.waitManager:addWait({
id = "opponent_thinking",
duration = GameConfig.OPPONENT_THINKING_TIME,
onComplete = function()
local opponentSelectedCard = self.opponent:getBestCard(self.firstPlayerCard)
print("Oponente revidou com: " .. opponentSelectedCard.name)
self.table:setOpponentCard(opponentSelectedCard)
self.waitManager:addWait({
id = "opponent_response_animation",
duration = GameConfig.CARD_ANIMATION_DURATION,
onComplete = function()
self:handleGameCalculation()
end
})
end,
onUpdate = function(____, progress)
end
})
end
function GameManager.prototype.handlePlayerResponse(self)
if self.gameState ~= ____exports.GameState.WAITING_PLAYER_INPUT then
return
end
if self.currentTurn ~= ____exports.TurnType.OPPONENT_FIRST then
return
end
local selectedCard = self.player:getSelectedCard()
self.table:setPlayerCard(selectedCard)
self.gameState = ____exports.GameState.PLAYER_TURN_ANIMATION
self.gameStateText = "Jogador revidou!"
self.waitManager:addWait({
id = "player_response_animation",
duration = GameConfig.CARD_ANIMATION_DURATION,
onComplete = function()
self:handleGameCalculation()
end,
onUpdate = function(____, progress)
end
})
end
function GameManager.prototype.update(self, dt)
if self.gameState == ____exports.GameState.MENU then
self.menuManager:update(dt)
return
end
self.waitManager:tick(dt)
self.table:tick(dt)
self.player.hand:updateState(self.std)
self.upgradeManager:updateState(self.std)
end
function GameManager.prototype.render(self)
if self.gameState == ____exports.GameState.MENU then
self.menuManager:render()
return
end
if self.gameState == ____exports.GameState.GAME_OVER then
self.std.draw.color(self.std.color.white)
self.std.text.font_size(50)
self.std.text.print_ex(
self.std.app.width / 2,
self.std.app.height / 2 - 50,
"Game Over",
0,
0
)
self.std.text.font_size(20)
self.std.draw.color(self.std.color.gray)
self.std.text.print_ex(
self.std.app.width / 2,
self.std.app.height / 2 + 20,
"A ou MENU para voltar ao menu",
0,
0
)
return
end
repeat
local ____switch76 = self.gameState
local ____cond76 = ____switch76 == ____exports.GameState.CHOOSING_UPGRADE
if ____cond76 then
self.upgradeManager:drawHandCards(self.std)
break
end
do
self.table:renderCurrentCard()
self.player.hand:drawHandCards(self.std, false)
self.opponent.hand:drawHandCards(self.std, true)
break
end
until true
end
function GameManager.prototype.getGameState(self)
return self.gameState
end
function GameManager.prototype.getGameStateText(self)
return self.gameStateText
end
function GameManager.prototype.getPlayer(self)
return self.player
end
function GameManager.prototype.getOpponent(self)
return self.opponent
end
function GameManager.prototype.getMenuManager(self)
return self.menuManager
end
return ____exports
end)
b334c[3] = r334c(3, function()
local ____exports = {}
____exports.GameConfig = {
HAND_SIZE = 7,
CARD_WIDTH = 71,
CARD_HEIGHT = 100,
CARD_SPACING = 20,
DEFAULT_OPPONENT_DUMBNESS = 50,
DUMBNESS_VARIATION = 25,
UPGRADE_CARDS_PER_SELECTION = 4,
UPGRADE_CARD_WIDTH = 107,
UPGRADE_CARD_HEIGHT = 150,
CARD_ANIMATION_DURATION = 0.5,
OPPONENT_THINKING_TIME = 1,
RESULT_CALCULATION_TIME = 1,
RESULT_DISPLAY_TIME = 1.5,
TABLE_CARD_WIDTH = 30,
TABLE_CARD_HEIGHT = 120,
PLAYER_CARD_OFFSET_X = -30,
PLAYER_CARD_OFFSET_Y = 30,
OPPONENT_CARD_OFFSET_X = 30,
OPPONENT_CARD_OFFSET_Y = -30,
CARD_BACK_TEXTURE = "Card_2.png",
CARD_DAMAGE_TEXTURE = "card_damage.png",
UI_FONT_SIZE_LARGE = 50,
UI_FONT_SIZE_MEDIUM = 16,
UI_FONT_SIZE_SMALL = 12,
UI_FONT_SIZE_TINY = 10,
UI_FONT_NAME = "tiny.ttf",
UI_BACKGROUND_ALPHA = 0.7,
UI_PLAYER_COLOR = {0, 100, 0, 0.7},
UI_OPPONENT_COLOR = {100, 0, 0, 0.7},
UI_INFO_COLOR = {0, 0, 0, 0.8},
MAX_DUPLICATE_CARDS_IN_HAND = 2,
MAX_HIGH_VALUE_CARDS_IN_HAND = 2,
HIGH_VALUE_CARD_THRESHOLD = 10,
VERY_DUMB_THRESHOLD = 70,
MEDIUM_DUMB_THRESHOLD = 25,
SPECIAL_EFFECTS = {
JACK = 1,
QUEEN = 2,
KING = 3,
RED_JOKER = 4,
BLACK_JOKER = 5
},
UPGRADE_EFFECTS = {
COMBO_NAIPES = 1,
CARTA_MARCADA = 2,
BARALHO_ENSANGUENTADO = 3,
ECO_INVERSO = 4,
PRESTIGIO_ANTIGO = 5,
NAIPE_CORINGA = 6,
PRESSAGIO_DERROTA = 7,
CORACAO_FRIO = 8,
RITUAL_DE_TRES = 9,
ORDEM_IMPLACAVEL = 10,
FALHA_CONTROLADA = 11,
AURA_INFLEXIVEL = 12
},
DEBUG_MODE = false,
SHOW_OPPONENT_CARDS = false,
LOG_CARD_SELECTIONS = true,
LOG_UPGRADE_EFFECTS = true
}
return ____exports
end)
b334c[4] = r334c(4, function()
local ____exports = {}
____exports.assets = {
"src/game/assets/bg.png:assets/bg.png",
"src/game/assets/cards/Diamonds_J.png:assets/cards/Diamonds_J.png",
"src/game/assets/cards/Clubs_6.png:assets/cards/Clubs_6.png",
"src/game/assets/cards/Spades_9.png:assets/cards/Spades_9.png",
"src/game/assets/cards/Hearts_5.png:assets/cards/Hearts_5.png",
"src/game/assets/cards/Spades_Q.png:assets/cards/Spades_Q.png",
"src/game/assets/cards/card8.png:assets/cards/card8.png",
"src/game/assets/cards/card10.png:assets/cards/card10.png",
"src/game/assets/cards/card12.png:assets/cards/card12.png",
"src/game/assets/cards/Clubs_4.png:assets/cards/Clubs_4.png",
"src/game/assets/cards/card9.png:assets/cards/card9.png",
"src/game/assets/cards/card7.png:assets/cards/card7.png",
"src/game/assets/cards/Card_5.png:assets/cards/Card_5.png",
"src/game/assets/cards/Card_2.png:assets/cards/Card_2.png",
"src/game/assets/cards/Spades_5.png:assets/cards/Spades_5.png",
"src/game/assets/cards/card11.png:assets/cards/card11.png",
"src/game/assets/cards/Spades_8.png:assets/cards/Spades_8.png",
"src/game/assets/cards/Clubs_10.png:assets/cards/Clubs_10.png",
"src/game/assets/cards/Hearts_ACE.png:assets/cards/Hearts_ACE.png",
"src/game/assets/cards/card3.png:assets/cards/card3.png",
"src/game/assets/cards/Hearts_K.png:assets/cards/Hearts_K.png",
"src/game/assets/cards/Hearts_6.png:assets/cards/Hearts_6.png",
"src/game/assets/cards/Diamonds_7.png:assets/cards/Diamonds_7.png",
"src/game/assets/cards/Hearts_7.png:assets/cards/Hearts_7.png",
"src/game/assets/cards/Hearts_Q.png:assets/cards/Hearts_Q.png",
"src/game/assets/cards/Hearts_8.png:assets/cards/Hearts_8.png",
"src/game/assets/cards/Spades_2.png:assets/cards/Spades_2.png",
"src/game/assets/cards/card4.png:assets/cards/card4.png",
"src/game/assets/cards/Hearts_4.png:assets/cards/Hearts_4.png",
"src/game/assets/cards/Diamonds_3.png:assets/cards/Diamonds_3.png",
"src/game/assets/cards/Spades_3.png:assets/cards/Spades_3.png",
"src/game/assets/cards/Diamonds_5.png:assets/cards/Diamonds_5.png",
"src/game/assets/cards/Hearts_J.png:assets/cards/Hearts_J.png",
"src/game/assets/cards/Clubs_K.png:assets/cards/Clubs_K.png",
"src/game/assets/cards/Clubs_Q.png:assets/cards/Clubs_Q.png",
"src/game/assets/cards/card_win.png:assets/cards/card_win.png",
"src/game/assets/cards/Hearts_2.png:assets/cards/Hearts_2.png",
"src/game/assets/cards/Joker_2.png:assets/cards/Joker_2.png",
"src/game/assets/cards/card1.png:assets/cards/card1.png",
"src/game/assets/cards/Hearts_3.png:assets/cards/Hearts_3.png",
"src/game/assets/cards/Diamonds_10.png:assets/cards/Diamonds_10.png",
"src/game/assets/cards/Diamonds_8.png:assets/cards/Diamonds_8.png",
"src/game/assets/cards/card_damage.png:assets/cards/card_damage.png",
"src/game/assets/cards/Diamonds_6.png:assets/cards/Diamonds_6.png",
"src/game/assets/cards/card5.png:assets/cards/card5.png",
"src/game/assets/cards/Clubs_5.png:assets/cards/Clubs_5.png",
"src/game/assets/cards/Diamonds_4.png:assets/cards/Diamonds_4.png",
"src/game/assets/cards/Spades_ACE.png:assets/cards/Spades_ACE.png",
"src/game/assets/cards/Diamonds_Q.png:assets/cards/Diamonds_Q.png",
"src/game/assets/cards/Diamonds_9.png:assets/cards/Diamonds_9.png",
"src/game/assets/cards/Clubs_9.png:assets/cards/Clubs_9.png",
"src/game/assets/cards/Clubs_J.png:assets/cards/Clubs_J.png",
"src/game/assets/cards/Spades_K.png:assets/cards/Spades_K.png",
"src/game/assets/cards/Clubs_8.png:assets/cards/Clubs_8.png",
"src/game/assets/cards/Spades_4.png:assets/cards/Spades_4.png",
"src/game/assets/cards/Spades_6.png:assets/cards/Spades_6.png",
"src/game/assets/cards/card2.png:assets/cards/card2.png",
"src/game/assets/cards/card6.png:assets/cards/card6.png",
"src/game/assets/cards/Diamonds_ACE.png:assets/cards/Diamonds_ACE.png",
"src/game/assets/cards/Clubs_2.png:assets/cards/Clubs_2.png",
"src/game/assets/cards/Hearts_9.png:assets/cards/Hearts_9.png",
"src/game/assets/cards/Clubs_3.png:assets/cards/Clubs_3.png",
"src/game/assets/cards/Card_3.png:assets/cards/Card_3.png",
"src/game/assets/cards/Spades_J.png:assets/cards/Spades_J.png",
"src/game/assets/cards/Clubs_7.png:assets/cards/Clubs_7.png",
"src/game/assets/cards/Diamonds_2.png:assets/cards/Diamonds_2.png",
"src/game/assets/cards/Joker_1.png:assets/cards/Joker_1.png",
"src/game/assets/cards/Card_1.png:assets/cards/Card_1.png",
"src/game/assets/cards/Card_4.png:assets/cards/Card_4.png",
"src/game/assets/cards/Clubs_ACE.png:assets/cards/Clubs_ACE.png",
"src/game/assets/cards/Hearts_10.png:assets/cards/Hearts_10.png",
"src/game/assets/cards/Spades_7.png:assets/cards/Spades_7.png",
"src/game/assets/cards/Diamonds_K.png:assets/cards/Diamonds_K.png",
"src/game/assets/cards/Spades_10.png:assets/cards/Spades_10.png"
}
return ____exports
end)
b334c[5] = r334c(5, function()
local function __TS__Class(self)
local c = {prototype = {}}
c.prototype.__index = c.prototype
c.prototype.constructor = c
return c
end
local function __TS__New(target, ...)
local instance = setmetatable({}, target.prototype)
instance:____constructor(...)
return instance
end
local ____exports = {}
local ____vector2 = b334c[12]('game_src_core_spatial_vector2')
local Vector2 = ____vector2.Vector2
local ____CardFactory = b334c[13]('game_src_game_utils_CardFactory')
local createCardInstance = ____CardFactory.createCardInstance
____exports.Table = __TS__Class()
local Table = ____exports.Table
Table.name = "Table"
function Table.prototype.____constructor(self, std)
self.cardWidth = 30
self.cardHeight = 120
self.playerHit = false
self.opponentHit = false
self.playerTimer = 0
self.opponentTimer = 0
self.playerCardTexture = ""
self.opponentCardTexture = ""
self.playerCardValue = 0
self.opponentCardValue = 0
self.std = std
end
function Table.prototype.setPlayerCard(self, card)
local instanceCard = createCardInstance(card)
local position = __TS__New(Vector2, self.std.app.width / 2 - self.cardWidth - 30, self.std.app.height / 2 - self.cardHeight + 30)
instanceCard.transform.position = position
self.lastPlayerCard = instanceCard
self.lastPlayerCard:up()
self.playerCardTexture = instanceCard.texture
end
function Table.prototype.cleanTable(self)
self.playerCardTexture = nil
self.lastPlayerCard = nil
self.opponentCardTexture = nil
self.lastOpponentCard = nil
end
function Table.prototype.setOpponentCard(self, card)
local instanceCard = createCardInstance(card)
local position = __TS__New(Vector2, self.std.app.width / 2 - self.cardWidth + 30, self.std.app.height / 2 - self.cardHeight - 30)
instanceCard.transform.position = position
self.lastOpponentCard = instanceCard
self.opponentCardTexture = instanceCard.texture
end
function Table.prototype.renderCurrentCard(self)
if self.lastOpponentCard and self.lastOpponentCard.texture then
self.lastOpponentCard:drawCard(self.std, false)
end
if self.lastPlayerCard and self.lastPlayerCard.texture then
self.lastPlayerCard:drawCard(self.std, false)
end
end
function Table.prototype.getPlayerCard(self)
if self.lastPlayerCard then
return self.lastPlayerCard
end
end
function Table.prototype.getOpponentCard(self)
if self.lastOpponentCard then
return self.lastOpponentCard
end
end
function Table.prototype.hitPlayer(self)
self.playerHit = true
end
function Table.prototype.hitOpponent(self)
self.opponentHit = true
end
function Table.prototype.applyHitOnPlayer(self, dt)
self.lastPlayerCard.texture = "card_damage.png"
if self.playerTimer <= 1 then
self.playerTimer = self.playerTimer + dt / 100
else
self.playerHit = false
self.playerTimer = 0
self.lastPlayerCard.texture = self.playerCardTexture
end
end
function Table.prototype.applyHitOnOpponent(self, dt)
self.lastOpponentCard.texture = "card_damage.png"
if self.opponentTimer <= 1 then
self.opponentTimer = self.opponentTimer + dt / 100
else
self.opponentHit = false
self.opponentTimer = 0
self.lastOpponentCard.texture = self.opponentCardTexture
end
end
function Table.prototype.applyWinOnPlayer(self, dt)
self.lastPlayerCard.texture = "card_win.png"
if self.playerTimer <= 1 then
self.playerTimer = self.playerTimer + dt / 100
else
self.playerHit = false
self.playerTimer = 0
self.lastPlayerCard.texture = self.playerCardTexture
end
end
function Table.prototype.applyWinOnOpponent(self, dt)
self.lastOpponentCard.texture = "card_win.png"
if self.opponentTimer <= 1 then
self.opponentTimer = self.opponentTimer + dt / 100
else
self.opponentHit = false
self.opponentTimer = 0
self.lastOpponentCard.texture = self.opponentCardTexture
end
end
function Table.prototype.tick(self, dt)
if self.playerHit then
self:applyHitOnPlayer(dt)
end
if self.opponentHit then
self:applyHitOnOpponent(dt)
end
end
return ____exports
end)
b334c[6] = r334c(6, function()
local function __TS__Class(self)
local c = {prototype = {}}
c.prototype.__index = c.prototype
c.prototype.constructor = c
return c
end
local function __TS__New(target, ...)
local instance = setmetatable({}, target.prototype)
instance:____constructor(...)
return instance
end
local function __TS__StringIncludes(self, searchString, position)
if not position then
position = 1
else
position = position + 1
end
local index = string.find(self, searchString, position, true)
return index ~= nil
end
local function __TS__ClassExtends(target, base)
target.____super = base
local staticMetatable = setmetatable({__index = base}, base)
setmetatable(target, staticMetatable)
local baseMetatable = getmetatable(base)
if baseMetatable then
if type(baseMetatable.__index) == "function" then
staticMetatable.__index = baseMetatable.__index
end
if type(baseMetatable.__newindex) == "function" then
staticMetatable.__newindex = baseMetatable.__newindex
end
end
setmetatable(target.prototype, base.prototype)
if type(base.prototype.__index) == "function" then
target.prototype.__index = base.prototype.__index
end
if type(base.prototype.__newindex) == "function" then
target.prototype.__newindex = base.prototype.__newindex
end
if type(base.prototype.__tostring) == "function" then
target.prototype.__tostring = base.prototype.__tostring
end
end
local Error, RangeError, ReferenceError, SyntaxError, TypeError, URIError
do
local function getErrorStack(self, constructor)
if debug == nil then
return nil
end
local level = 1
while true do
local info = debug.getinfo(level, "f")
level = level + 1
if not info then
level = 1
break
elseif info.func == constructor then
break
end
end
if __TS__StringIncludes(_VERSION, "Lua 5.0") then
return debug.traceback(("[Level " .. tostring(level)) .. "]")
elseif _VERSION == "Lua 5.1" then
return string.sub(
debug.traceback("", level),
2
)
else
return debug.traceback(nil, level)
end
end
local function wrapErrorToString(self, getDescription)
return function(self)
local description = getDescription(self)
local caller = debug.getinfo(3, "f")
local isClassicLua = __TS__StringIncludes(_VERSION, "Lua 5.0")
if isClassicLua or caller and caller.func ~= error then
return description
else
return (description .. "\n") .. tostring(self.stack)
end
end
end
local function initErrorClass(self, Type, name)
Type.name = name
return setmetatable(
Type,
{__call = function(____, _self, message) return __TS__New(Type, message) end}
)
end
local ____initErrorClass_1 = initErrorClass
local ____class_0 = __TS__Class()
____class_0.name = ""
function ____class_0.prototype.____constructor(self, message)
if message == nil then
message = ""
end
self.message = message
self.name = "Error"
self.stack = getErrorStack(nil, __TS__New)
local metatable = getmetatable(self)
if metatable and not metatable.__errorToStringPatched then
metatable.__errorToStringPatched = true
metatable.__tostring = wrapErrorToString(nil, metatable.__tostring)
end
end
function ____class_0.prototype.__tostring(self)
return self.message ~= "" and (self.name .. ": ") .. self.message or self.name
end
Error = ____initErrorClass_1(nil, ____class_0, "Error")
local function createErrorClass(self, name)
local ____initErrorClass_3 = initErrorClass
local ____class_2 = __TS__Class()
____class_2.name = ____class_2.name
__TS__ClassExtends(____class_2, Error)
function ____class_2.prototype.____constructor(self, ...)
____class_2.____super.prototype.____constructor(self, ...)
self.name = name
end
return ____initErrorClass_3(nil, ____class_2, name)
end
RangeError = createErrorClass(nil, "RangeError")
ReferenceError = createErrorClass(nil, "ReferenceError")
SyntaxError = createErrorClass(nil, "SyntaxError")
TypeError = createErrorClass(nil, "TypeError")
URIError = createErrorClass(nil, "URIError")
end
local function __TS__ArrayUnshift(self, ...)
local items = {...}
local numItemsToInsert = #items
if numItemsToInsert == 0 then
return #self
end
for i = #self, 1, -1 do
self[i + numItemsToInsert] = self[i]
end
for i = 1, numItemsToInsert do
self[i] = items[i]
end
return #self
end
local ____exports = {}
local ____hand = b334c[14]('game_src_game_entities_hand')
local Hand = ____hand.Hand
____exports.Player = __TS__Class()
local Player = ____exports.Player
Player.name = "Player"
function Player.prototype.____constructor(self)
self.hand = __TS__New(Hand)
self.upgrades = {}
self.matchPoints = 0
self.cardHistory = {}
self.cardHistory = {}
end
function Player.prototype.getSelectedCard(self)
local card = self.hand:getSelectedCard()
if not card then
error(
__TS__New(Error, "No card selected"),
0
)
end
print("Player selected: " .. card.name)
__TS__ArrayUnshift(self.cardHistory, card)
self.hand:removeCardById(card.id)
return card
end
function Player.prototype.getLastCard(self)
return self.cardHistory[1]
end
function Player.prototype.getCardHistory(self)
return self.cardHistory
end
function Player.prototype.addUpgrade(self, upgrade)
local ____self_upgrades_0 = self.upgrades
____self_upgrades_0[#____self_upgrades_0 + 1] = upgrade
print("Added upgrade: " .. upgrade.name)
end
function Player.prototype.getUpgrades(self)
return self.upgrades
end
function Player.prototype.getMatchPoints(self)
return self.matchPoints
end
function Player.prototype.getHandCards(self)
return self.hand:getAllCards()
end
function Player.prototype.hasCards(self)
return #self.hand:getAllCards() > 0
end
function Player.prototype.resetForNewMatch(self)
self.matchPoints = 0
self.cardHistory = {}
end
function Player.prototype.resetCompletely(self)
self.matchPoints = 0
self.cardHistory = {}
self.upgrades = {}
end
return ____exports
end)
b334c[7] = r334c(7, function()
local function __TS__Class(self)
local c = {prototype = {}}
c.prototype.__index = c.prototype
c.prototype.constructor = c
return c
end
local function __TS__New(target, ...)
local instance = setmetatable({}, target.prototype)
instance:____constructor(...)
return instance
end
local function __TS__ArrayUnshift(self, ...)
local items = {...}
local numItemsToInsert = #items
if numItemsToInsert == 0 then
return #self
end
for i = #self, 1, -1 do
self[i + numItemsToInsert] = self[i]
end
for i = 1, numItemsToInsert do
self[i] = items[i]
end
return #self
end
local function __TS__ArraySort(self, compareFn)
if compareFn ~= nil then
table.sort(
self,
function(a, b) return compareFn(nil, a, b) < 0 end
)
else
table.sort(self)
end
return self
end
local function __TS__StringIncludes(self, searchString, position)
if not position then
position = 1
else
position = position + 1
end
local index = string.find(self, searchString, position, true)
return index ~= nil
end
local function __TS__ClassExtends(target, base)
target.____super = base
local staticMetatable = setmetatable({__index = base}, base)
setmetatable(target, staticMetatable)
local baseMetatable = getmetatable(base)
if baseMetatable then
if type(baseMetatable.__index) == "function" then
staticMetatable.__index = baseMetatable.__index
end
if type(baseMetatable.__newindex) == "function" then
staticMetatable.__newindex = baseMetatable.__newindex
end
end
setmetatable(target.prototype, base.prototype)
if type(base.prototype.__index) == "function" then
target.prototype.__index = base.prototype.__index
end
if type(base.prototype.__newindex) == "function" then
target.prototype.__newindex = base.prototype.__newindex
end
if type(base.prototype.__tostring) == "function" then
target.prototype.__tostring = base.prototype.__tostring
end
end
local Error, RangeError, ReferenceError, SyntaxError, TypeError, URIError
do
local function getErrorStack(self, constructor)
if debug == nil then
return nil
end
local level = 1
while true do
local info = debug.getinfo(level, "f")
level = level + 1
if not info then
level = 1
break
elseif info.func == constructor then
break
end
end
if __TS__StringIncludes(_VERSION, "Lua 5.0") then
return debug.traceback(("[Level " .. tostring(level)) .. "]")
elseif _VERSION == "Lua 5.1" then
return string.sub(
debug.traceback("", level),
2
)
else
return debug.traceback(nil, level)
end
end
local function wrapErrorToString(self, getDescription)
return function(self)
local description = getDescription(self)
local caller = debug.getinfo(3, "f")
local isClassicLua = __TS__StringIncludes(_VERSION, "Lua 5.0")
if isClassicLua or caller and caller.func ~= error then
return description
else
return (description .. "\n") .. tostring(self.stack)
end
end
end
local function initErrorClass(self, Type, name)
Type.name = name
return setmetatable(
Type,
{__call = function(____, _self, message) return __TS__New(Type, message) end}
)
end
local ____initErrorClass_1 = initErrorClass
local ____class_0 = __TS__Class()
____class_0.name = ""
function ____class_0.prototype.____constructor(self, message)
if message == nil then
message = ""
end
self.message = message
self.name = "Error"
self.stack = getErrorStack(nil, __TS__New)
local metatable = getmetatable(self)
if metatable and not metatable.__errorToStringPatched then
metatable.__errorToStringPatched = true
metatable.__tostring = wrapErrorToString(nil, metatable.__tostring)
end
end
function ____class_0.prototype.__tostring(self)
return self.message ~= "" and (self.name .. ": ") .. self.message or self.name
end
Error = ____initErrorClass_1(nil, ____class_0, "Error")
local function createErrorClass(self, name)
local ____initErrorClass_3 = initErrorClass
local ____class_2 = __TS__Class()
____class_2.name = ____class_2.name
__TS__ClassExtends(____class_2, Error)
function ____class_2.prototype.____constructor(self, ...)
____class_2.____super.prototype.____constructor(self, ...)
self.name = name
end
return ____initErrorClass_3(nil, ____class_2, name)
end
RangeError = createErrorClass(nil, "RangeError")
ReferenceError = createErrorClass(nil, "ReferenceError")
SyntaxError = createErrorClass(nil, "SyntaxError")
TypeError = createErrorClass(nil, "TypeError")
URIError = createErrorClass(nil, "URIError")
end
local function __TS__ArrayFilter(self, callbackfn, thisArg)
local result = {}
local len = 0
for i = 1, #self do
if callbackfn(thisArg, self[i], i - 1, self) then
len = len + 1
result[len] = self[i]
end
end
return result
end
local function __TS__ArrayForEach(self, callbackFn, thisArg)
for i = 1, #self do
callbackFn(thisArg, self[i], i - 1, self)
end
end
local ____exports = {}
local ____vector2 = b334c[12]('game_src_core_spatial_vector2')
local Vector2 = ____vector2.Vector2
local ____hand = b334c[14]('game_src_game_entities_hand')
local Hand = ____hand.Hand
____exports.Opponent = __TS__Class()
local Opponent = ____exports.Opponent
Opponent.name = "Opponent"
function Opponent.prototype.____constructor(self, baseDumbness)
self.matchPoints = 0
self.hand = __TS__New(Hand)
self.baseDumbness = baseDumbness
self.cardHistory = {}
print("New opponent created with dumbness:", baseDumbness)
end
function Opponent.prototype.removeSelectedCard(self, card)
__TS__ArrayUnshift(self.cardHistory, card)
self.hand:removeCardById(card.id)
end
function Opponent.prototype.generateNewHand(self, deck)
print("# Generating New Opponent Hand #")
self.hand.cards = {}
do
local i = 0
while i < self.hand.cardsQuantity do
local newCard = self.hand:getNewCard(deck)
print("Got card:", newCard.name)
local cardCount = 0
local highCardCount = 0
do
local n = 0
while n < #self.hand.cards do
if cardCount >= 2 then
break
end
if highCardCount >= 2 then
break
end
local card = self.hand.cards[n + 1]
if card.id == newCard.id then
cardCount = cardCount + 1
end
if card.value >= 10 then
highCardCount = highCardCount + 1
end
n = n + 1
end
end
if cardCount >= 2 or highCardCount >= 2 then
local reserveCard = self.hand:getNewCard(deck)
local attempts = 0
while newCard.id == reserveCard.id and attempts < 10 do
reserveCard = self.hand:getNewCard(deck)
attempts = attempts + 1
end
local ____self_hand_cards_0 = self.hand.cards
____self_hand_cards_0[#____self_hand_cards_0 + 1] = reserveCard
else
local ____self_hand_cards_1 = self.hand.cards
____self_hand_cards_1[#____self_hand_cards_1 + 1] = newCard
end
i = i + 1
end
end
print("Finished generating opponent hand with", #self.hand.cards, "cards")
end
function Opponent.prototype.getLastCard(self)
return self.cardHistory[1]
end
function Opponent.prototype.getCardHistory(self)
return self.cardHistory
end
function Opponent.prototype.getMatchPoints(self)
return self.matchPoints
end
function Opponent.prototype.getBestCard(self, playerCard)
local cards = __TS__ArraySort(
self.hand:getAllCards(),
function(____, a, b) return a.value - b.value end
)
if #cards == 0 then
error(
__TS__New(Error, "Opponent has no cards left"),
0
)
end
local winningCards = __TS__ArrayFilter(
cards,
function(____, item) return item.value > playerCard.value end
)
local loseCards = __TS__ArrayFilter(
cards,
function(____, item) return item.value < playerCard.value end
)
local equalCards = __TS__ArrayFilter(
cards,
function(____, item) return item.value == playerCard.value end
)
local variation = 25
local dumbness = math.min(
100,
math.max(
0,
self.baseDumbness + (math.random() * 2 - 1) * variation
)
)
local selectedCard
if dumbness >= 70 then
local ____temp_3
if #loseCards > 0 then
____temp_3 = loseCards
else
local ____temp_2
if #equalCards > 0 then
____temp_2 = equalCards
else
____temp_2 = winningCards
end
____temp_3 = ____temp_2
end
local pool = ____temp_3
selectedCard = pool[math.floor(math.random() * #pool) + 1]
elseif dumbness >= 25 then
selectedCard = cards[math.floor(math.random() * #cards) + 1]
else
if #winningCards > 0 then
selectedCard = winningCards[1]
else
selectedCard = cards[1]
end
end
print((((("Opponent chose: " .. selectedCard.name) .. " (value: ") .. tostring(selectedCard.value)) .. ") against player's ") .. tostring(playerCard.value))
self:removeSelectedCard(selectedCard)
return selectedCard
end
function Opponent.prototype.setCardsPosition(self, screenWidth, screenHeight)
local spacing = 20
local cardWidth = 71
local cardHeight = 100
local totalWidth = #self.hand.cards * spacing + (#self.hand.cards - 1) * cardWidth
local x = (screenWidth - totalWidth) / 2
__TS__ArrayForEach(
self.hand.cards,
function(____, card)
card.transform.position = __TS__New(Vector2, x, cardHeight + 50)
x = x + (cardWidth + spacing)
end
)
end
function Opponent.prototype.hideCards(self)
__TS__ArrayForEach(
self.hand.cards,
function(____, card)
card.texture = "Card_2.png"
end
)
end
function Opponent.prototype.resetForNewMatch(self)
self.matchPoints = 0
self.cardHistory = {}
end
return ____exports
end)
b334c[8] = r334c(8, function()
local function __TS__Class(self)
local c = {prototype = {}}
c.prototype.__index = c.prototype
c.prototype.constructor = c
return c
end
local function __TS__New(target, ...)
local instance = setmetatable({}, target.prototype)
instance:____constructor(...)
return instance
end
local function __TS__ArrayForEach(self, callbackFn, thisArg)
for i = 1, #self do
callbackFn(thisArg, self[i], i - 1, self)
end
end
local ____exports = {}
local ____vector2 = b334c[12]('game_src_core_spatial_vector2')
local Vector2 = ____vector2.Vector2
local ____upgradeDeck = b334c[15]('game_src_game_upgrades_upgradeDeck')
local UpgradeDeck = ____upgradeDeck.UpgradeDeck
local ____UpgradeDefinitions = b334c[16]('game_src_game_data_UpgradeDefinitions')
local UPGRADE_CARD_LIST = ____UpgradeDefinitions.UPGRADE_CARD_LIST
____exports.UpgradeManager = __TS__Class()
local UpgradeManager = ____exports.UpgradeManager
UpgradeManager.name = "UpgradeManager"
function UpgradeManager.prototype.____constructor(self, player)
self.UPGRADE_QUANTITY = 2
self.cardsQuantity = 4
self.selectedCard = 0
self.player = player
self.upgradeDeck = __TS__New(UpgradeDeck, UPGRADE_CARD_LIST)
self.upgradeDeck:generateNewUpgrades(self.UPGRADE_QUANTITY)
self.upgrades = self.upgradeDeck:getUpgradeCards()
end
function UpgradeManager.prototype.drawHandCards(self, std)
__TS__ArrayForEach(
self.upgrades,
function(____, card)
card:drawCard(std)
end
)
end
function UpgradeManager.prototype.updateState(self, std)
__TS__ArrayForEach(
self.upgrades,
function(____, card)
card:update(std)
end
)
end
function UpgradeManager.prototype.switchActiveCard(self, sum)
if sum then
if self.selectedCard < #self.upgrades - 1 then
self.selectedCard = self.selectedCard + 1
self.upgrades[self.selectedCard + 1]:up()
do
local i = 0
while i < #self.upgrades do
local card = self.upgrades[i + 1]
if i ~= self.selectedCard then
card:down()
end
i = i + 1
end
end
end
else
if self.selectedCard >= 1 then
self.selectedCard = self.selectedCard - 1
self.upgrades[self.selectedCard + 1]:up()
do
local i = 0
while i < #self.upgrades do
local card = self.upgrades[i + 1]
if i ~= self.selectedCard then
card:down()
end
i = i + 1
end
end
end
end
end
function UpgradeManager.prototype.setSelectedCard(self, index)
if index >= 0 and index < #self.upgrades - 1 then
self.selectedCard = index
else
print("Invalid card index")
end
end
function UpgradeManager.prototype.getAllupgradeDeck(self)
return self.upgrades
end
function UpgradeManager.prototype.setCardsCenterPosition(self, screenWidth, screenHeight)
local spacing = 20
local cardWidth = 107
local cardHeight = 150
local totalWidth = #self.upgrades * spacing + (#self.upgrades - 1) * cardWidth
local x = (screenWidth - totalWidth) / 2
__TS__ArrayForEach(
self.upgrades,
function(____, card)
card.transform.position = __TS__New(Vector2, x, screenHeight / 2 - cardHeight)
x = x + (cardWidth + spacing)
end
)
end
function UpgradeManager.prototype.getSelectedUpgrade(self)
return self.upgrades[self.selectedCard + 1]
end
return ____exports
end)
b334c[9] = r334c(9, function()
local function __TS__Class(self)
local c = {prototype = {}}
c.prototype.__index = c.prototype
c.prototype.constructor = c
return c
end
local function __TS__ArrayFindIndex(self, callbackFn, thisArg)
for i = 1, #self do
if callbackFn(thisArg, self[i], i - 1, self) then
return i - 1
end
end
return -1
end
local function __TS__CountVarargs(...)
return select("#", ...)
end
local function __TS__ArraySplice(self, ...)
local args = {...}
local len = #self
local actualArgumentCount = __TS__CountVarargs(...)
local start = args[1]
local deleteCount = args[2]
if start < 0 then
start = len + start
if start < 0 then
start = 0
end
elseif start > len then
start = len
end
local itemCount = actualArgumentCount - 2
if itemCount < 0 then
itemCount = 0
end
local actualDeleteCount
if actualArgumentCount == 0 then
actualDeleteCount = 0
elseif actualArgumentCount == 1 then
actualDeleteCount = len - start
else
actualDeleteCount = deleteCount or 0
if actualDeleteCount < 0 then
actualDeleteCount = 0
end
if actualDeleteCount > len - start then
actualDeleteCount = len - start
end
end
local out = {}
for k = 1, actualDeleteCount do
local from = start + k
if self[from] ~= nil then
out[k] = self[from]
end
end
if itemCount < actualDeleteCount then
for k = start + 1, len - actualDeleteCount do
local from = k + actualDeleteCount
local to = k + itemCount
if self[from] then
self[to] = self[from]
else
self[to] = nil
end
end
for k = len - actualDeleteCount + itemCount + 1, len do
self[k] = nil
end
elseif itemCount > actualDeleteCount then
for k = len - actualDeleteCount, start + 1, -1 do
local from = k + actualDeleteCount
local to = k + itemCount
if self[from] then
self[to] = self[from]
else
self[to] = nil
end
end
end
local j = start + 1
for i = 3, actualArgumentCount do
self[j] = args[i]
j = j + 1
end
for k = #self, len - actualDeleteCount + itemCount + 1, -1 do
self[k] = nil
end
return out
end
local function __TS__ArraySome(self, callbackfn, thisArg)
for i = 1, #self do
if callbackfn(thisArg, self[i], i - 1, self) then
return true
end
end
return false
end
local function __TS__ArrayFind(self, predicate, thisArg)
for i = 1, #self do
local elem = self[i]
if predicate(thisArg, elem, i - 1, self) then
return elem
end
end
return nil
end
local function __TS__ArrayMap(self, callbackfn, thisArg)
local result = {}
for i = 1, #self do
result[i] = callbackfn(thisArg, self[i], i - 1, self)
end
return result
end
local ____exports = {}
____exports.WaitManager = __TS__Class()
local WaitManager = ____exports.WaitManager
WaitManager.name = "WaitManager"
function WaitManager.prototype.____constructor(self)
self.waitQueue = {}
end
function WaitManager.prototype.addWait(self, config)
self:removeWait(config.id)
local waitItem = {
id = config.id,
duration = config.duration,
elapsed = 0,
onComplete = config.onComplete,
onUpdate = config.onUpdate
}
local ____self_waitQueue_0 = self.waitQueue
____self_waitQueue_0[#____self_waitQueue_0 + 1] = waitItem
print(((("Added wait: " .. config.id) .. " for ") .. tostring(config.duration)) .. "s")
end
function WaitManager.prototype.removeWait(self, id)
local index = __TS__ArrayFindIndex(
self.waitQueue,
function(____, item) return item.id == id end
)
if index ~= -1 then
__TS__ArraySplice(self.waitQueue, index, 1)
print("Removed wait: " .. id)
end
end
function WaitManager.prototype.clear(self)
print(("Clearing " .. tostring(#self.waitQueue)) .. " waits")
self.waitQueue = {}
end
function WaitManager.prototype.tick(self, deltaTime)
local ____temp_1
if deltaTime > 1 then
____temp_1 = deltaTime / 1000
else
____temp_1 = deltaTime
end
local dt = ____temp_1
do
local i = #self.waitQueue - 1
while i >= 0 do
local waitItem = self.waitQueue[i + 1]
waitItem.elapsed = waitItem.elapsed + dt
local progress = math.min(waitItem.elapsed / waitItem.duration, 1)
if waitItem.onUpdate then
waitItem:onUpdate(progress)
end
if waitItem.elapsed >= waitItem.duration then
waitItem:onComplete()
__TS__ArraySplice(self.waitQueue, i, 1)
print("Completed wait: " .. waitItem.id)
end
i = i - 1
end
end
end
function WaitManager.prototype.hasWait(self, id)
return __TS__ArraySome(
self.waitQueue,
function(____, item) return item.id == id end
)
end
function WaitManager.prototype.getWaitProgress(self, id)
local waitItem = __TS__ArrayFind(
self.waitQueue,
function(____, item) return item.id == id end
)
if not waitItem then
return 0
end
return math.min(waitItem.elapsed / waitItem.duration, 1)
end
function WaitManager.prototype.getActiveWaits(self)
return __TS__ArrayMap(
self.waitQueue,
function(____, item) return item.id end
)
end
return ____exports
end)
b334c[10] = r334c(10, function()
local ____exports = {}
____exports.CARD_LIST = {
{
id = "clubs_2",
name = "2 of Clubs",
texture = "Clubs_2.png",
value = 2,
is_special = 0,
special_effect = 0
},
{
id = "clubs_3",
name = "3 of Clubs",
texture = "Clubs_3.png",
value = 3,
is_special = 0,
special_effect = 0
},
{
id = "clubs_4",
name = "4 of Clubs",
texture = "Clubs_4.png",
value = 4,
is_special = 0,
special_effect = 0
},
{
id = "clubs_5",
name = "5 of Clubs",
texture = "Clubs_5.png",
value = 5,
is_special = 0,
special_effect = 0
},
{
id = "clubs_6",
name = "6 of Clubs",
texture = "Clubs_6.png",
value = 6,
is_special = 0,
special_effect = 0
},
{
id = "clubs_7",
name = "7 of Clubs",
texture = "Clubs_7.png",
value = 7,
is_special = 0,
special_effect = 0
},
{
id = "clubs_8",
name = "8 of Clubs",
texture = "Clubs_8.png",
value = 8,
is_special = 0,
special_effect = 0
},
{
id = "clubs_9",
name = "9 of Clubs",
texture = "Clubs_9.png",
value = 9,
is_special = 0,
special_effect = 0
},
{
id = "clubs_10",
name = "10 of Clubs",
texture = "Clubs_10.png",
value = 10,
is_special = 0,
special_effect = 0
},
{
id = "clubs_ace",
name = "Ace of Clubs",
texture = "Clubs_ACE.png",
value = 11,
is_special = 0,
special_effect = 0
},
{
id = "clubs_j",
name = "Jack of Clubs",
texture = "Clubs_J.png",
value = 12,
is_special = 1,
special_effect = 1
},
{
id = "clubs_q",
name = "Queen of Clubs",
texture = "Clubs_Q.png",
value = 13,
is_special = 1,
special_effect = 2
},
{
id = "clubs_k",
name = "King of Clubs",
texture = "Clubs_K.png",
value = 14,
is_special = 1,
special_effect = 3
},
{
id = "diamonds_2",
name = "2 of Diamonds",
texture = "Diamonds_2.png",
value = 2,
is_special = 0,
special_effect = 0
},
{
id = "diamonds_3",
name = "3 of Diamonds",
texture = "Diamonds_3.png",
value = 3,
is_special = 0,
special_effect = 0
},
{
id = "diamonds_4",
name = "4 of Diamonds",
texture = "Diamonds_4.png",
value = 4,
is_special = 0,
special_effect = 0
},
{
id = "diamonds_5",
name = "5 of Diamonds",
texture = "Diamonds_5.png",
value = 5,
is_special = 0,
special_effect = 0
},
{
id = "diamonds_6",
name = "6 of Diamonds",
texture = "Diamonds_6.png",
value = 6,
is_special = 0,
special_effect = 0
},
{
id = "diamonds_7",
name = "7 of Diamonds",
texture = "Diamonds_7.png",
value = 7,
is_special = 0,
special_effect = 0
},
{
id = "diamonds_8",
name = "8 of Diamonds",
texture = "Diamonds_8.png",
value = 8,
is_special = 0,
special_effect = 0
},
{
id = "diamonds_9",
name = "9 of Diamonds",
texture = "Diamonds_9.png",
value = 9,
is_special = 0,
special_effect = 0
},
{
id = "diamonds_10",
name = "10 of Diamonds",
texture = "Diamonds_10.png",
value = 10,
is_special = 0,
special_effect = 0
},
{
id = "diamonds_ace",
name = "Ace of Diamonds",
texture = "Diamonds_ACE.png",
value = 11,
is_special = 0,
special_effect = 0
},
{
id = "diamonds_j",
name = "Jack of Diamonds",
texture = "Diamonds_J.png",
value = 12,
is_special = 1,
special_effect = 1
},
{
id = "diamonds_q",
name = "Queen of Diamonds",
texture = "Diamonds_Q.png",
value = 13,
is_special = 1,
special_effect = 2
},
{
id = "diamonds_k",
name = "King of Diamonds",
texture = "Diamonds_K.png",
value = 14,
is_special = 1,
special_effect = 3
},
{
id = "hearts_2",
name = "2 of Hearts",
texture = "Hearts_2.png",
value = 2,
is_special = 0,
special_effect = 0
},
{
id = "hearts_3",
name = "3 of Hearts",
texture = "Hearts_3.png",
value = 3,
is_special = 0,
special_effect = 0
},
{
id = "hearts_4",
name = "4 of Hearts",
texture = "Hearts_4.png",
value = 4,
is_special = 0,
special_effect = 0
},
{
id = "hearts_5",
name = "5 of Hearts",
texture = "Hearts_5.png",
value = 5,
is_special = 0,
special_effect = 0
},
{
id = "hearts_6",
name = "6 of Hearts",
texture = "Hearts_6.png",
value = 6,
is_special = 0,
special_effect = 0
},
{
id = "hearts_7",
name = "7 of Hearts",
texture = "Hearts_7.png",
value = 7,
is_special = 0,
special_effect = 0
},
{
id = "hearts_8",
name = "8 of Hearts",
texture = "Hearts_8.png",
value = 8,
is_special = 0,
special_effect = 0
},
{
id = "hearts_9",
name = "9 of Hearts",
texture = "Hearts_9.png",
value = 9,
is_special = 0,
special_effect = 0
},
{
id = "hearts_10",
name = "10 of Hearts",
texture = "Hearts_10.png",
value = 10,
is_special = 0,
special_effect = 0
},
{
id = "hearts_ace",
name = "Ace of Hearts",
texture = "Hearts_ACE.png",
value = 11,
is_special = 0,
special_effect = 0
},
{
id = "hearts_j",
name = "Jack of Hearts",
texture = "Hearts_J.png",
value = 12,
is_special = 1,
special_effect = 1
},
{
id = "hearts_q",
name = "Queen of Hearts",
texture = "Hearts_Q.png",
value = 13,
is_special = 1,
special_effect = 2
},
{
id = "hearts_k",
name = "King of Hearts",
texture = "Hearts_K.png",
value = 14,
is_special = 1,
special_effect = 3
},
{
id = "spades_2",
name = "2 of Spades",
texture = "Spades_2.png",
value = 2,
is_special = 0,
special_effect = 0
},
{
id = "spades_3",
name = "3 of Spades",
texture = "Spades_3.png",
value = 3,
is_special = 0,
special_effect = 0
},
{
id = "spades_4",
name = "4 of Spades",
texture = "Spades_4.png",
value = 4,
is_special = 0,
special_effect = 0
},
{
id = "spades_5",
name = "5 of Spades",
texture = "Spades_5.png",
value = 5,
is_special = 0,
special_effect = 0
},
{
id = "spades_6",
name = "6 of Spades",
texture = "Spades_6.png",
value = 6,
is_special = 0,
special_effect = 0
},
{
id = "spades_7",
name = "7 of Spades",
texture = "Spades_7.png",
value = 7,
is_special = 0,
special_effect = 0
},
{
id = "spades_8",
name = "8 of Spades",
texture = "Spades_8.png",
value = 8,
is_special = 0,
special_effect = 0
},
{
id = "spades_9",
name = "9 of Spades",
texture = "Spades_9.png",
value = 9,
is_special = 0,
special_effect = 0
},
{
id = "spades_10",
name = "10 of Spades",
texture = "Spades_10.png",
value = 10,
is_special = 0,
special_effect = 0
},
{
id = "spades_ace",
name = "Ace of Spades",
texture = "Spades_ACE.png",
value = 11,
is_special = 0,
special_effect = 0
},
{
id = "spades_j",
name = "Jack of Spades",
texture = "Spades_J.png",
value = 12,
is_special = 1,
special_effect = 1
},
{
id = "spades_q",
name = "Queen of Spades",
texture = "Spades_Q.png",
value = 13,
is_special = 1,
special_effect = 2
},
{
id = "spades_k",
name = "King of Spades",
texture = "Spades_K.png",
value = 14,
is_special = 1,
special_effect = 3
},
{
id = "joker_red",
name = "Red Joker",
texture = "Joker_1.png",
value = 15,
is_special = 1,
special_effect = 4
},
{
id = "joker_black",
name = "Black Joker",
texture = "Joker_2.png",
value = 15,
is_special = 1,
special_effect = 5
}
}
return ____exports
end)
b334c[11] = r334c(11, function()
local function __TS__Class(self)
local c = {prototype = {}}
c.prototype.__index = c.prototype
c.prototype.constructor = c
return c
end
local function __TS__New(target, ...)
local instance = setmetatable({}, target.prototype)
instance:____constructor(...)
return instance
end
local function __TS__StringIncludes(self, searchString, position)
if not position then
position = 1
else
position = position + 1
end
local index = string.find(self, searchString, position, true)
return index ~= nil
end
local function __TS__StringStartsWith(self, searchString, position)
if position == nil or position < 0 then
position = 0
end
return string.sub(self, position + 1, #searchString + position) == searchString
end
local function __TS__StringTrim(self)
local result = string.gsub(self, "^[%s ﻿]*(.-)[%s ﻿]*$", "%1")
return result
end
local ____exports = {}
local ____waitManager = b334c[9]('game_src_core_utils_waitManager')
local WaitManager = ____waitManager.WaitManager
local ____GameConfig = b334c[3]('game_src_game_config_GameConfig')
local GameConfig = ____GameConfig.GameConfig
____exports.MenuState = ____exports.MenuState or ({})
____exports.MenuState.MAIN_MENU = "MAIN_MENU"
____exports.MenuState.TUTORIAL = "TUTORIAL"
____exports.MenuState.CREDITS = "CREDITS"
____exports.MenuState.GAME = "GAME"
____exports.TutorialStep = ____exports.TutorialStep or ({})
____exports.TutorialStep.WELCOME = 0
____exports.TutorialStep[____exports.TutorialStep.WELCOME] = "WELCOME"
____exports.TutorialStep.GAME_OVERVIEW = 1
____exports.TutorialStep[____exports.TutorialStep.GAME_OVERVIEW] = "GAME_OVERVIEW"
____exports.TutorialStep.HAND_BASICS = 2
____exports.TutorialStep[____exports.TutorialStep.HAND_BASICS] = "HAND_BASICS"
____exports.TutorialStep.CARD_SELECTION = 3
____exports.TutorialStep[____exports.TutorialStep.CARD_SELECTION] = "CARD_SELECTION"
____exports.TutorialStep.TURN_SYSTEM = 4
____exports.TutorialStep[____exports.TutorialStep.TURN_SYSTEM] = "TURN_SYSTEM"
____exports.TutorialStep.COMBAT_ATTACK = 5
____exports.TutorialStep[____exports.TutorialStep.COMBAT_ATTACK] = "COMBAT_ATTACK"
____exports.TutorialStep.COMBAT_RESPONSE = 6
____exports.TutorialStep[____exports.TutorialStep.COMBAT_RESPONSE] = "COMBAT_RESPONSE"
____exports.TutorialStep.SCORING_SYSTEM = 7
____exports.TutorialStep[____exports.TutorialStep.SCORING_SYSTEM] = "SCORING_SYSTEM"
____exports.TutorialStep.CARD_VALUES = 8
____exports.TutorialStep[____exports.TutorialStep.CARD_VALUES] = "CARD_VALUES"
____exports.TutorialStep.STRATEGY_TIPS = 9
____exports.TutorialStep[____exports.TutorialStep.STRATEGY_TIPS] = "STRATEGY_TIPS"
____exports.TutorialStep.UPGRADES_INTRO = 10
____exports.TutorialStep[____exports.TutorialStep.UPGRADES_INTRO] = "UPGRADES_INTRO"
____exports.TutorialStep.UPGRADES_EFFECTS = 11
____exports.TutorialStep[____exports.TutorialStep.UPGRADES_EFFECTS] = "UPGRADES_EFFECTS"
____exports.TutorialStep.WIN_CONDITIONS = 12
____exports.TutorialStep[____exports.TutorialStep.WIN_CONDITIONS] = "WIN_CONDITIONS"
____exports.TutorialStep.COMPLETE = 13
____exports.TutorialStep[____exports.TutorialStep.COMPLETE] = "COMPLETE"
____exports.MenuManager = __TS__Class()
local MenuManager = ____exports.MenuManager
MenuManager.name = "MenuManager"
function MenuManager.prototype.____constructor(self, std)
self.menuState = ____exports.MenuState.MAIN_MENU
self.tutorialStep = ____exports.TutorialStep.WELCOME
self.mainMenuOptions = {"Jogar", "Tutorial", "Créditos"}
self.selectedMainOption = 0
self.tutorialTexts = {
{title = "Bem-vindo ao Card Game!", content = {
"Este é um jogo de cartas estratégico onde você",
"enfrenta um oponente inteligente em batalhas",
"táticas usando cartas numeradas.",
"",
"Prepare-se para uma experiência que combina",
"estratégia, timing e um pouco de sorte!",
"",
"Use ← → para navegar nos menus",
"Pressione A para confirmar",
"",
"Pressione A para começar o tutorial..."
}},
{title = "Visão Geral do Jogo", content = {
"OBJETIVO:",
"Ganhe mais pontos que seu oponente",
"ao final de todas as rodadas!",
"",
"ELEMENTOS PRINCIPAIS:",
"• Sua mão: 5 cartas com valores únicos",
"• Mesa: onde as cartas são jogadas",
"• Pontuação: quem ganha mais rodadas vence",
"• Upgrades: poderes especiais obtidos",
"",
"Pressione A para continuar..."
}},
{title = "Sua Mão de Cartas", content = {
"Você começa cada partida com 5 cartas",
"na sua mão, cada uma com um valor diferente.",
"",
"CARACTERÍSTICAS DAS CARTAS:",
"• Valores de 1 a 13 (como cartas normais)",
"• Diferentes naipes: ♠ ♥ ♦ ♣",
"• Algumas podem ter efeitos especiais",
"",
"Sua mão fica na parte inferior da tela,",
"sempre visível para você planejar sua estratégia.",
"",
"Pressione A para continuar..."
}},
{title = "Selecionando Cartas", content = {
"NAVEGAÇÃO:",
"• Use ← → para escolher entre suas cartas",
"• A carta selecionada fica destacada (sobe)",
"• Pressione A para jogar a carta escolhida",
"",
"DICA IMPORTANTE:",
"Uma vez jogada, você não pode recuperar",
"a carta! Pense bem antes de confirmar.",
"",
"O oponente não vê qual carta você",
"selecionou até você jogar.",
"",
"Pressione A para continuar..."
}},
{title = "Sistema de Turnos Alternados", content = {
"O jogo usa um sistema de ATAQUE e RESPOSTA:",
"",
"RODADA ÍMPAR (1, 3, 5...):",
"→ Você ataca primeiro",
"→ Oponente responde vendo sua carta",
"",
"RODADA PAR (2, 4, 6...):",
"→ Oponente ataca primeiro",
"→ Você responde vendo a carta dele",
"",
"VANTAGEM DE ATACAR:",
"O defensor vê a carta do atacante antes",
"de escolher sua resposta!",
"",
"Pressione A para continuar..."
}},
{title = "Fase de Ataque", content = {
"Quando você ATACA primeiro:",
"",
"1. Escolha sua carta sem ver a do oponente",
"2. Sua carta é revelada na mesa",
"3. O oponente vê sua carta",
"4. Oponente escolhe sua resposta",
"5. Cartas são comparadas",
"",
"ESTRATÉGIA:",
"• Cartas altas: mais chances de ganhar",
"• Cartas médias: podem surpreender",
"• Cartas baixas: economize as altas!",
"",
"Pressione A para continuar..."
}},
{title = "Fase de Resposta", content = {
"Quando você RESPONDE a um ataque:",
"",
"1. Oponente joga primeira carta",
"2. Você vê o valor da carta dele",
"3. Escolha sua melhor resposta",
"4. Cartas são comparadas",
"",
"VANTAGEM DA RESPOSTA:",
"• Você sabe exatamente o que precisa",
"• Pode usar a menor carta que ganhe",
"• Ou jogar carta baixa se não pode ganhar",
"",
"Esta informação é CRUCIAL para vencer!",
"",
"Pressione A para continuar..."
}},
{title = "Sistema de Pontuação", content = {
"COMO GANHAR PONTOS:",
"",
"✓ Carta com MAIOR valor ganha a rodada",
"✓ Ganhador recebe 1 ponto de partida",
"✓ Em caso de empate: ninguém ganha ponto",
"",
"FIM DE PARTIDA:",
"Quando todas as cartas acabam (5 rodadas),",
"quem tiver mais pontos VENCE a partida!",
"",
"Possível: 3x2, 4x1, 5x0, ou até 0x0",
"",
"Pressione A para continuar..."
}},
{title = "Valores e Naipes das Cartas", content = {
"VALORES DAS CARTAS:",
"• Ás = 1 (menor valor)",
"• Números = 2, 3, 4, 5, 6, 7, 8, 9, 10",
"• Valete = 11",
"• Dama = 12",
"• Rei = 13 (maior valor)",
"",
"NAIPES:",
"♠ Espadas, ♥ Copas, ♦ Ouros, ♣ Paus",
"",
"IMPORTANTE: Naipes podem ativar combos",
"especiais com certos upgrades!",
"",
"Pressione A para continuar..."
}},
{title = "Dicas Estratégicas", content = {
"GERENCIAMENTO DE RECURSOS:",
"• Não desperdice cartas altas cedo demais",
"• Guarde Reis (13) para momentos críticos",
"• Use cartas baixas quando souber que vai perder",
"",
"LEITURA DO OPONENTE:",
"• Observe quais cartas ele já jogou",
"• Estime que cartas ainda tem na mão",
"• Adapte sua estratégia ao comportamento dele",
"",
"TIMING É TUDO!",
"",
"Pressione A para continuar..."
}},
{title = "Sistema de Upgrades", content = {
"Ao VENCER uma partida completa, você",
"pode escolher um UPGRADE especial!",
"",
"COMO FUNCIONA:",
"• Aparecem 3 opções de upgrade",
"• Use ← → para navegar",
"• Pressione A para escolher",
"",
"PERMANÊNCIA:",
"Upgrades são permanentes e se acumulam!",
"Cada vitória = novo upgrade adquirido.",
"",
"Estratégia evolui conforme você progride!",
"",
"Pressione A para continuar..."
}},
{title = "Efeitos dos Upgrades", content = {
"EXEMPLO - COMBO DE NAIPES:",
"",
"Se você jogar 3 cartas consecutivas",
"do mesmo naipe (♠♠♠ ou ♥♥♥), a terceira",
"carta tem seu valor DOBRADO!",
"",
"Exemplo: Rei de Copas (13) vira 26!",
"",
"OUTROS UPGRADES:",
"Cada upgrade oferece diferentes",
"vantagens táticas. Experimente",
"combinações para criar sua estratégia ideal!",
"",
"Pressione A para continuar..."
}},
{title = "Condições de Vitória", content = {
"PARA VENCER UMA PARTIDA:",
"• Ganhe mais rodadas que o oponente",
"• Máximo: 5 rodadas por partida",
"• Mínimo para vencer: 3 rodadas",
"",
"PROGRESSÃO NO JOGO:",
"• Vitória = Escolha de upgrade",
"• Derrota = Game Over (volta ao menu)",
"• Cada partida fica mais desafiadora",
"",
"OBJETIVO FINAL:",
"Colete upgrades e desenvolva a",
"estratégia perfeita para dominar!",
"",
"Pressione A para finalizar tutorial..."
}}
}
self.tutorialAnimTime = 0
self.creditsAnimTime = 0
self.std = std
self.waitManager = __TS__New(WaitManager)
end
function MenuManager.prototype.handleInput(self, key)
repeat
local ____switch4 = self.menuState
local ____cond4 = ____switch4 == ____exports.MenuState.MAIN_MENU
if ____cond4 then
return self:handleMainMenuInput(key)
end
____cond4 = ____cond4 or ____switch4 == ____exports.MenuState.TUTORIAL
if ____cond4 then
return self:handleTutorialInput(key)
end
____cond4 = ____cond4 or ____switch4 == ____exports.MenuState.CREDITS
if ____cond4 then
return self:handleCreditsInput(key)
end
do
return false
end
until true
end
function MenuManager.prototype.handleMainMenuInput(self, key)
repeat
local ____switch6 = key
local ____cond6 = ____switch6 == "up" or ____switch6 == "left"
if ____cond6 then
if self.selectedMainOption > 0 then
self.selectedMainOption = self.selectedMainOption - 1
end
return true
end
____cond6 = ____cond6 or (____switch6 == "down" or ____switch6 == "right")
if ____cond6 then
if self.selectedMainOption < #self.mainMenuOptions - 1 then
self.selectedMainOption = self.selectedMainOption + 1
end
return true
end
____cond6 = ____cond6 or ____switch6 == "action"
if ____cond6 then
self:selectMainMenuOption()
return true
end
until true
return false
end
function MenuManager.prototype.handleTutorialInput(self, key)
repeat
local ____switch10 = key
local ____cond10 = ____switch10 == "action"
if ____cond10 then
if self.tutorialStep < ____exports.TutorialStep.COMPLETE then
self.tutorialStep = self.tutorialStep + 1
if self.tutorialStep == ____exports.TutorialStep.COMPLETE then
self.menuState = ____exports.MenuState.MAIN_MENU
self.tutorialStep = ____exports.TutorialStep.WELCOME
end
end
return true
end
____cond10 = ____cond10 or ____switch10 == "menu"
if ____cond10 then
self.menuState = ____exports.MenuState.MAIN_MENU
self.tutorialStep = ____exports.TutorialStep.WELCOME
return true
end
____cond10 = ____cond10 or ____switch10 == "left"
if ____cond10 then
if self.tutorialStep > ____exports.TutorialStep.WELCOME then
self.tutorialStep = self.tutorialStep - 1
end
return true
end
____cond10 = ____cond10 or ____switch10 == "right"
if ____cond10 then
if self.tutorialStep < ____exports.TutorialStep.COMPLETE then
self.tutorialStep = self.tutorialStep + 1
if self.tutorialStep == ____exports.TutorialStep.COMPLETE then
self.menuState = ____exports.MenuState.MAIN_MENU
self.tutorialStep = ____exports.TutorialStep.WELCOME
end
end
return true
end
until true
return false
end
function MenuManager.prototype.handleCreditsInput(self, key)
repeat
local ____switch17 = key
local ____cond17 = ____switch17 == "menu" or ____switch17 == "action"
if ____cond17 then
self.menuState = ____exports.MenuState.MAIN_MENU
return true
end
until true
return false
end
function MenuManager.prototype.selectMainMenuOption(self)
repeat
local ____switch19 = self.selectedMainOption
local ____cond19 = ____switch19 == 0
if ____cond19 then
self.menuState = ____exports.MenuState.GAME
break
end
____cond19 = ____cond19 or ____switch19 == 1
if ____cond19 then
self.menuState = ____exports.MenuState.TUTORIAL
self.tutorialStep = ____exports.TutorialStep.WELCOME
break
end
____cond19 = ____cond19 or ____switch19 == 2
if ____cond19 then
self.menuState = ____exports.MenuState.CREDITS
break
end
until true
end
function MenuManager.prototype.update(self, dt)
self.waitManager:tick(dt)
if self.menuState == ____exports.MenuState.TUTORIAL then
self.tutorialAnimTime = self.tutorialAnimTime + dt / 1000
end
if self.menuState == ____exports.MenuState.CREDITS then
self.creditsAnimTime = self.creditsAnimTime + dt / 1000
end
if self.tutorialAnimTime > 1000 then
self.tutorialAnimTime = 0
end
if self.creditsAnimTime > 1000 then
self.creditsAnimTime = 0
end
end
function MenuManager.prototype.render(self)
repeat
local ____switch26 = self.menuState
local ____cond26 = ____switch26 == ____exports.MenuState.MAIN_MENU
if ____cond26 then
self:renderMainMenu()
break
end
____cond26 = ____cond26 or ____switch26 == ____exports.MenuState.TUTORIAL
if ____cond26 then
self:renderTutorial()
break
end
____cond26 = ____cond26 or ____switch26 == ____exports.MenuState.CREDITS
if ____cond26 then
self:renderCredits()
break
end
until true
end
function MenuManager.prototype.renderMainMenu(self)
local centerX = self.std.app.width / 2
local centerY = self.std.app.height / 2
local time = self.tutorialAnimTime
self.std.draw.color(self.std.color.black)
self.std.draw.rect(
0,
0,
0,
self.std.app.width,
self.std.app.height
)
self.std.draw.color(self.std.color.darkpurple)
self.std.draw.rect(
0,
0,
0,
self.std.app.width,
self.std.app.height / 3
)
self.std.draw.color(self.std.color.maroon)
self.std.draw.rect(
0,
0,
self.std.app.height * 2 / 3,
self.std.app.width,
self.std.app.height / 3
)
do
local i = 0
while i < 5 do
local offsetX = math.sin(time + i) * 20
local offsetY = math.cos(time * 0.5 + i) * 15
local cardX = 100 + i * 200 + offsetX
local cardY = 150 + offsetY
self.std.draw.color(self.std.color.darkgray)
self.std.draw.rect(
0,
cardX,
cardY,
60,
80
)
self.std.draw.color(self.std.color.lightgray)
self.std.draw.rect(
1,
cardX,
cardY,
60,
80
)
i = i + 1
end
end
local menuBoxWidth = 400
local menuBoxHeight = 350
local boxX = centerX - menuBoxWidth / 2
local boxY = centerY - menuBoxHeight / 2
self.std.draw.color(self.std.color.black)
self.std.draw.rect(
0,
boxX + 8,
boxY + 8,
menuBoxWidth,
menuBoxHeight
)
self.std.draw.color(self.std.color.darkblue)
self.std.draw.rect(
0,
boxX,
boxY,
menuBoxWidth,
menuBoxHeight
)
self.std.draw.color(self.std.color.gold)
self.std.draw.rect(
1,
boxX,
boxY,
menuBoxWidth,
menuBoxHeight
)
self.std.draw.rect(
1,
boxX + 4,
boxY + 4,
menuBoxWidth - 8,
menuBoxHeight - 8
)
self.std.text.font_size(52)
self.std.text.font_name(GameConfig.UI_FONT_NAME)
self.std.draw.color(self.std.color.black)
self.std.text.print_ex(
centerX + 3,
centerY - 130 + 3,
"CARD GAME",
0,
0
)
local titlePulse = 1 + math.sin(time * 2) * 0.05
self.std.text.font_size(52 * titlePulse)
self.std.draw.color(self.std.color.gold)
self.std.text.print_ex(
centerX,
centerY - 130,
"CARD GAME",
0,
0
)
self.std.text.font_size(18)
local ____temp_0
if math.sin(time) > 0 then
____temp_0 = self.std.color.skyblue
else
____temp_0 = self.std.color.lightgray
end
local subtitleColor = ____temp_0
self.std.draw.color(subtitleColor)
self.std.text.print_ex(
centerX,
centerY - 95,
"⚔️ Estratégia • Fortuna • Vitória ⚔️",
0,
0
)
self.std.draw.color(self.std.color.gold)
self.std.draw.line(centerX - 100, centerY - 75, centerX + 100, centerY - 75)
self.std.text.font_size(26)
local startY = centerY - 30
local spacing = 50
do
local i = 0
while i < #self.mainMenuOptions do
local y = startY + i * spacing
local optionWidth = 250
local optionHeight = 40
local optionX = centerX - optionWidth / 2
local optionY = y - optionHeight / 2
if i == self.selectedMainOption then
self.std.draw.color(self.std.color.gold)
self.std.draw.rect(
0,
optionX - 5,
optionY - 5,
optionWidth + 10,
optionHeight + 10
)
self.std.draw.color(self.std.color.darkblue)
self.std.draw.rect(
0,
optionX,
optionY,
optionWidth,
optionHeight
)
self.std.draw.color(self.std.color.yellow)
self.std.draw.rect(
1,
optionX + 2,
optionY + 2,
optionWidth - 4,
optionHeight - 4
)
self.std.draw.color(self.std.color.yellow)
self.std.text.print_ex(
optionX + 20,
y,
"►",
0,
0
)
self.std.text.print_ex(
optionX + optionWidth - 20,
y,
"◄",
0,
0
)
self.std.draw.color(self.std.color.white)
self.std.text.print_ex(
centerX,
y,
self.mainMenuOptions[i + 1],
0,
0
)
if math.sin(time * 6) > 0.5 then
self.std.draw.color(self.std.color.white)
self.std.draw.rect(
1,
optionX,
optionY,
optionWidth,
optionHeight
)
end
else
self.std.draw.color(self.std.color.gray)
self.std.draw.rect(
1,
optionX + 10,
optionY + 5,
optionWidth - 20,
optionHeight - 10
)
self.std.draw.color(self.std.color.lightgray)
self.std.text.print_ex(
centerX,
y,
self.mainMenuOptions[i + 1],
0,
0
)
end
i = i + 1
end
end
local instructionY = self.std.app.height - 80
self.std.draw.color(self.std.color.darkgray)
self.std.draw.rect(
0,
50,
instructionY - 10,
self.std.app.width - 100,
60
)
self.std.draw.color(self.std.color.skyblue)
self.std.draw.rect(
1,
50,
instructionY - 10,
self.std.app.width - 100,
60
)
self.std.text.font_size(16)
self.std.draw.color(self.std.color.white)
self.std.text.print_ex(
centerX,
instructionY + 10,
"🎮 Use ← → para navegar • Pressione A para selecionar",
0,
0
)
self.std.text.print_ex(
centerX,
instructionY + 30,
"📱 MENU para resetar jogo",
0,
0
)
self.std.text.font_size(12)
self.std.draw.color(self.std.color.gray)
self.std.text.print_ex(
self.std.app.width - 80,
self.std.app.height - 20,
"v1.0.0",
0,
0
)
do
local i = 0
while i < 8 do
local particleX = (centerX + math.sin(time + i * 0.8) * 200) % self.std.app.width
local particleY = (100 + math.cos(time * 0.7 + i) * 50) % self.std.app.height
if math.sin(time * 2 + i) > 0.7 then
self.std.draw.color(self.std.color.gold)
self.std.text.font_size(8)
self.std.text.print_ex(
particleX,
particleY,
"✦",
0,
0
)
end
i = i + 1
end
end
end
function MenuManager.prototype.renderTutorial(self)
local centerX = self.std.app.width / 2
local centerY = self.std.app.height / 2
local time = self.tutorialAnimTime
self.std.draw.color(self.std.color.darkgreen)
self.std.draw.rect(
0,
0,
0,
self.std.app.width,
self.std.app.height
)
self.std.draw.color(self.std.color.black)
self.std.draw.rect(
0,
0,
0,
self.std.app.width,
60
)
self.std.draw.rect(
0,
0,
self.std.app.height - 60,
self.std.app.width,
60
)
local panelWidth = self.std.app.width - 120
local panelHeight = self.std.app.height - 180
local panelX = centerX - panelWidth / 2
local panelY = centerY - panelHeight / 2
self.std.draw.color(self.std.color.black)
self.std.draw.rect(
0,
panelX + 6,
panelY + 6,
panelWidth,
panelHeight
)
self.std.draw.color(self.std.color.white)
self.std.draw.rect(
0,
panelX,
panelY,
panelWidth,
panelHeight
)
self.std.draw.color(self.std.color.darkgreen)
self.std.draw.rect(
1,
panelX + 2,
panelY + 2,
panelWidth - 4,
panelHeight - 4
)
local headerHeight = 80
self.std.draw.color(self.std.color.darkgreen)
self.std.draw.rect(
0,
panelX + 2,
panelY + 2,
panelWidth - 4,
headerHeight
)
local currentTutorial = self.tutorialTexts[self.tutorialStep + 1]
self.std.text.font_size(32)
self.std.draw.color(self.std.color.gold)
self.std.text.print_ex(
centerX,
panelY + 35,
currentTutorial.title,
0,
0
)
local lineWidth = math.abs(math.sin(time * 2)) * 200 + 100
self.std.draw.color(self.std.color.gold)
self.std.draw.line(centerX - lineWidth / 2, panelY + 55, centerX + lineWidth / 2, panelY + 55)
self.std.text.font_size(18)
local contentStartY = panelY + 100
local lineHeight = 25
do
local i = 0
while i < #currentTutorial.content do
do
local __continue40
repeat
local y = contentStartY + i * lineHeight
local line = currentTutorial.content[i + 1]
if __TS__StringIncludes(line, "OBJETIVO:") or __TS__StringIncludes(line, "COMO FUNCIONA:") or __TS__StringIncludes(line, "VANTAGEM:") or __TS__StringIncludes(line, "IMPORTANTE:") or __TS__StringIncludes(line, "ESTRATÉGIA:") or __TS__StringIncludes(line, "DICA:") then
self.std.draw.color(self.std.color.maroon)
self.std.text.font_size(22)
elseif __TS__StringStartsWith(line, "•") or __TS__StringStartsWith(line, "→") or __TS__StringStartsWith(line, "✓") then
self.std.draw.color(self.std.color.darkblue)
self.std.text.font_size(18)
elseif __TS__StringIncludes(line, "RODADA") or __TS__StringIncludes(line, "ELEMENTOS") or __TS__StringIncludes(line, "CARACTERÍSTICAS") or __TS__StringIncludes(line, "PERMANÊNCIA:") or __TS__StringIncludes(line, "NAVEGAÇÃO:") or __TS__StringIncludes(line, "PROGRESSÃO:") then
self.std.draw.color(self.std.color.purple)
self.std.text.font_size(19)
elseif line == "" or __TS__StringTrim(line) == "" then
__continue40 = true
break
else
self.std.draw.color(self.std.color.black)
self.std.text.font_size(18)
end
self.std.text.print_ex(
centerX,
y,
line,
0,
0
)
__continue40 = true
until true
if not __continue40 then
break
end
end
i = i + 1
end
end
local footerY = panelY + panelHeight - 70
self.std.draw.color(self.std.color.lightgray)
self.std.draw.rect(
0,
panelX + 2,
footerY,
panelWidth - 4,
68
)
self.std.text.font_size(16)
self.std.draw.color(self.std.color.darkgreen)
local progressText = (("Página " .. tostring(self.tutorialStep + 1)) .. " de ") .. tostring(#self.tutorialTexts)
self.std.text.print_ex(
self.std.app.width - 120,
footerY + 20,
progressText,
0,
0
)
local progressBarWidth = 300
local progressBarHeight = 12
local progressBarX = centerX - progressBarWidth / 2
local progressBarY = footerY + 15
self.std.draw.color(self.std.color.darkgray)
self.std.draw.rect(
0,
progressBarX,
progressBarY,
progressBarWidth,
progressBarHeight
)
local progressWidth = progressBarWidth * (self.tutorialStep + 1) / #self.tutorialTexts
self.std.draw.color(self.std.color.green)
self.std.draw.rect(
0,
progressBarX,
progressBarY,
progressWidth,
progressBarHeight
)
self.std.draw.color(self.std.color.gold)
self.std.draw.rect(
1,
progressBarX,
progressBarY,
progressBarWidth,
progressBarHeight
)
do
local i = 1
while i < #self.tutorialTexts do
local markerX = progressBarX + progressBarWidth * i / #self.tutorialTexts
self.std.draw.color(self.std.color.white)
self.std.draw.line(markerX, progressBarY, markerX, progressBarY + progressBarHeight)
i = i + 1
end
end
local buttonY = footerY + 45
local buttonPulse = 1 + math.sin(time * 4) * 0.1
if math.sin(time * 3) > 0 then
self.std.draw.color(self.std.color.gold)
self.std.text.font_size(22 * buttonPulse)
self.std.text.print_ex(
centerX,
buttonY,
"🎯 A para continuar",
0,
0
)
else
self.std.draw.color(self.std.color.orange)
self.std.text.font_size(20)
self.std.text.print_ex(
centerX,
buttonY,
"A para continuar",
0,
0
)
end
self.std.text.font_size(14)
self.std.draw.color(self.std.color.gray)
self.std.text.print_ex(
100,
footerY + 15,
"← → navegação",
0,
0
)
self.std.text.print_ex(
100,
footerY + 35,
"MENU voltar",
0,
0
)
local sideDecoY = centerY
self.std.draw.color(self.std.color.gold)
self.std.text.font_size(24)
self.std.text.print_ex(
80,
sideDecoY - 60,
"♠",
0,
0
)
self.std.text.print_ex(
80,
sideDecoY - 20,
"♥",
0,
0
)
self.std.text.print_ex(
80,
sideDecoY + 20,
"♦",
0,
0
)
self.std.text.print_ex(
80,
sideDecoY + 60,
"♣",
0,
0
)
self.std.text.print_ex(
self.std.app.width - 80,
sideDecoY - 60,
"♣",
0,
0
)
self.std.text.print_ex(
self.std.app.width - 80,
sideDecoY - 20,
"♦",
0,
0
)
self.std.text.print_ex(
self.std.app.width - 80,
sideDecoY + 20,
"♥",
0,
0
)
self.std.text.print_ex(
self.std.app.width - 80,
sideDecoY + 60,
"♠",
0,
0
)
if math.sin(time * 2) > 0.8 then
self.std.draw.color(self.std.color.white)
self.std.text.font_size(28)
self.std.text.print_ex(
80,
sideDecoY,
"✨",
0,
0
)
self.std.text.print_ex(
self.std.app.width - 80,
sideDecoY,
"✨",
0,
0
)
end
end
function MenuManager.prototype.renderCredits(self)
local centerX = self.std.app.width / 2
local centerY = self.std.app.height / 2
local time = self.creditsAnimTime
self.std.draw.color(self.std.color.black)
self.std.draw.rect(
0,
0,
0,
self.std.app.width,
self.std.app.height
)
self.std.draw.color(self.std.color.maroon)
self.std.draw.rect(
0,
0,
0,
self.std.app.width,
self.std.app.height / 2
)
self.std.draw.color(self.std.color.darkpurple)
self.std.draw.rect(
0,
0,
self.std.app.height / 2,
self.std.app.width,
self.std.app.height / 2
)
local panelWidth = 500
local panelHeight = 400
local panelX = centerX - panelWidth / 2
local panelY = centerY - panelHeight / 2
self.std.draw.color(self.std.color.black)
self.std.draw.rect(
0,
panelX + 8,
panelY + 8,
panelWidth,
panelHeight
)
self.std.draw.color(self.std.color.darkblue)
self.std.draw.rect(
0,
panelX,
panelY,
panelWidth,
panelHeight
)
self.std.draw.color(self.std.color.gold)
self.std.draw.rect(
1,
panelX,
panelY,
panelWidth,
panelHeight
)
self.std.draw.rect(
1,
panelX + 4,
panelY + 4,
panelWidth - 8,
panelHeight - 8
)
self.std.text.font_size(42)
self.std.text.font_name(GameConfig.UI_FONT_NAME)
self.std.draw.color(self.std.color.black)
self.std.text.print_ex(
centerX + 3,
centerY - 150 + 3,
"CRÉDITOS",
0,
0
)
local titlePulse = 1 + math.sin(time * 1.5) * 0.08
self.std.text.font_size(42 * titlePulse)
self.std.draw.color(self.std.color.gold)
self.std.text.print_ex(
centerX,
centerY - 150,
"CRÉDITOS",
0,
0
)
self.std.draw.color(self.std.color.gold)
self.std.draw.line(centerX - 120, centerY - 125, centerX + 120, centerY - 125)
local credits = {
{text = "Desenvolvido com ❤️", style = "header", color = "white"},
{text = "", style = "spacer", color = ""},
{text = "TECNOLOGIAS:", style = "section", color = "skyblue"},
{text = "Engine: Gamely Framework", style = "item", color = "lightgray"},
{text = "Linguagem: TypeScript", style = "item", color = "lightgray"},
{text = "Renderização: Canvas 2D", style = "item", color = "lightgray"},
{text = "", style = "spacer", color = ""},
{text = "DESIGN:", style = "section", color = "skyblue"},
{text = "Sistema de turnos alternados", style = "item", color = "lightgray"},
{text = "Mecânicas de upgrade progressivo", style = "item", color = "lightgray"},
{text = "Interface responsiva e intuitiva", style = "item", color = "lightgray"},
{text = "", style = "spacer", color = ""},
{text = "🎮 Obrigado por jogar! 🎮", style = "footer", color = "yellow"},
{text = "", style = "spacer", color = ""},
{text = "Versão 1.0.0 - 2025", style = "version", color = "gray"}
}
local startY = centerY - 100
local currentY = startY
local lineSpacing = 25
do
local i = 0
while i < #credits do
do
local __continue53
repeat
local credit = credits[i + 1]
if credit.style == "spacer" then
currentY = currentY + lineSpacing * 0.5
__continue53 = true
break
end
repeat
local ____switch55 = credit.style
local ____cond55 = ____switch55 == "header"
if ____cond55 then
self.std.text.font_size(24)
self.std.draw.color(self.std.color.white)
break
end
____cond55 = ____cond55 or ____switch55 == "section"
if ____cond55 then
self.std.text.font_size(20)
self.std.draw.color(self.std.color.skyblue)
break
end
____cond55 = ____cond55 or ____switch55 == "item"
if ____cond55 then
self.std.text.font_size(18)
self.std.draw.color(self.std.color.lightgray)
break
end
____cond55 = ____cond55 or ____switch55 == "footer"
if ____cond55 then
self.std.text.font_size(22)
self.std.draw.color(self.std.color.yellow)
break
end
____cond55 = ____cond55 or ____switch55 == "version"
if ____cond55 then
self.std.text.font_size(16)
self.std.draw.color(self.std.color.gray)
break
end
do
self.std.text.font_size(18)
self.std.draw.color(self.std.color.lightgray)
end
until true
self.std.text.print_ex(
centerX,
currentY,
credit.text,
0,
0
)
currentY = currentY + lineSpacing
__continue53 = true
until true
if not __continue53 then
break
end
end
i = i + 1
end
end
local heartScale = 1 + math.sin(time * 4) * 0.3
if math.sin(time * 4) > 0.5 then
self.std.draw.color(self.std.color.red)
self.std.text.font_size(28 * heartScale)
self.std.text.print_ex(
centerX + 105,
startY,
"❤️",
0,
0
)
end
do
local i = 0
while i < 6 do
local starX = centerX + math.sin(time * 0.8 + i * 1.2) * 180
local starY = centerY + math.cos(time * 0.6 + i * 0.9) * 120
if math.sin(time * 3 + i) > 0.6 then
self.std.draw.color(self.std.color.gold)
self.std.text.font_size(12)
self.std.text.print_ex(
starX,
starY,
"⭐",
0,
0
)
end
i = i + 1
end
end
local instructionY = self.std.app.height - 80
self.std.draw.color(self.std.color.darkgray)
self.std.draw.rect(
0,
100,
instructionY - 10,
self.std.app.width - 200,
50
)
self.std.draw.color(self.std.color.gold)
self.std.draw.rect(
1,
100,
instructionY - 10,
self.std.app.width - 200,
50
)
self.std.text.font_size(18)
local ____temp_1
if math.sin(time * 2) > 0 then
____temp_1 = self.std.color.white
else
____temp_1 = self.std.color.yellow
end
local instructionPulse = ____temp_1
self.std.draw.color(instructionPulse)
self.std.text.print_ex(
centerX,
instructionY + 15,
"🎮 A ou MENU para voltar ao menu principal",
0,
0
)
do
local i = 0
while i < 10 do
local particleX = (50 + i * 100 + math.sin(time + i) * 30) % self.std.app.width
local particleY = (80 + math.cos(time * 0.7 + i) * 40) % (self.std.app.height - 160)
if math.sin(time * 1.5 + i) > 0.8 then
self.std.draw.color(self.std.color.gold)
self.std.text.font_size(8)
self.std.text.print_ex(
particleX,
particleY + 80,
"✦",
0,
0
)
end
i = i + 1
end
end
self.std.draw.color(self.std.color.gold)
self.std.text.font_size(32)
self.std.text.print_ex(
centerX,
40,
"👑",
0,
0
)
end
function MenuManager.prototype.drawAnimatedBorder(self, x, y, width, height, time)
local borderOffset = math.sin(time * 4) * 2
self.std.draw.color(self.std.color.gold)
self.std.draw.rect(
1,
x - borderOffset,
y - borderOffset,
width + borderOffset * 2,
height + borderOffset * 2
)
end
function MenuManager.prototype.drawGlowEffect(self, x, y, text, baseSize, time)
local glowIntensity = (math.sin(time * 3) + 1) / 2
local glowSize = baseSize + glowIntensity * 4
self.std.draw.color(self.std.color.yellow)
self.std.text.font_size(glowSize)
self.std.text.print_ex(
x + 1,
y + 1,
text,
0,
0
)
self.std.draw.color(self.std.color.white)
self.std.text.font_size(baseSize)
self.std.text.print_ex(
x,
y,
text,
0,
0
)
end
function MenuManager.prototype.renderFloatingParticles(self, time, count)
if count == nil then
count = 8
end
do
local i = 0
while i < count do
local particleX = (self.std.app.width / 2 + math.sin(time + i * 0.8) * 300) % self.std.app.width
local particleY = (100 + math.cos(time * 0.7 + i) * 80) % (self.std.app.height - 100)
if math.sin(time * 2 + i) > 0.7 then
self.std.draw.color(self.std.color.gold)
self.std.text.font_size(10)
self.std.text.print_ex(
particleX,
particleY,
"✦",
0,
0
)
end
i = i + 1
end
end
end
function MenuManager.prototype.getMenuState(self)
return self.menuState
end
function MenuManager.prototype.getTutorialStep(self)
return self.tutorialStep
end
function MenuManager.prototype.isInGame(self)
return self.menuState == ____exports.MenuState.GAME
end
function MenuManager.prototype.isInTutorial(self)
return self.menuState == ____exports.MenuState.TUTORIAL
end
function MenuManager.prototype.isInCredits(self)
return self.menuState == ____exports.MenuState.CREDITS
end
function MenuManager.prototype.isInMainMenu(self)
return self.menuState == ____exports.MenuState.MAIN_MENU
end
function MenuManager.prototype.startGame(self)
self.menuState = ____exports.MenuState.GAME
end
function MenuManager.prototype.returnToMenu(self)
self.menuState = ____exports.MenuState.MAIN_MENU
self.selectedMainOption = 0
self.tutorialStep = ____exports.TutorialStep.WELCOME
end
function MenuManager.prototype.goToCredits(self)
self.menuState = ____exports.MenuState.CREDITS
self.creditsAnimTime = 0
end
function MenuManager.prototype.goToTutorial(self)
self.menuState = ____exports.MenuState.TUTORIAL
self.tutorialStep = ____exports.TutorialStep.WELCOME
self.tutorialAnimTime = 0
end
function MenuManager.prototype.getCurrentMenuOption(self)
if self.menuState == ____exports.MenuState.MAIN_MENU then
return self.mainMenuOptions[self.selectedMainOption + 1]
end
return ""
end
function MenuManager.prototype.getTutorialProgress(self)
return (self.tutorialStep + 1) / #self.tutorialTexts
end
function MenuManager.prototype.getTutorialTitle(self)
if self.tutorialStep < #self.tutorialTexts then
return self.tutorialTexts[self.tutorialStep + 1].title
end
return ""
end
function MenuManager.prototype.reset(self)
self.menuState = ____exports.MenuState.MAIN_MENU
self.tutorialStep = ____exports.TutorialStep.WELCOME
self.selectedMainOption = 0
self.tutorialAnimTime = 0
self.creditsAnimTime = 0
end
function MenuManager.prototype.skipToTutorialEnd(self)
if self.menuState == ____exports.MenuState.TUTORIAL then
self.tutorialStep = ____exports.TutorialStep.COMPLETE
self.menuState = ____exports.MenuState.MAIN_MENU
self.tutorialStep = ____exports.TutorialStep.WELCOME
end
end
function MenuManager.prototype.canNavigateBack(self)
return self.menuState == ____exports.MenuState.TUTORIAL and self.tutorialStep > ____exports.TutorialStep.WELCOME
end
function MenuManager.prototype.canNavigateForward(self)
return self.menuState == ____exports.MenuState.TUTORIAL and self.tutorialStep < ____exports.TutorialStep.COMPLETE
end
function MenuManager.prototype.dispose(self)
self.waitManager = nil
self.std = nil
end
return ____exports
end)
b334c[12] = r334c(12, function()
local function __TS__Class(self)
local c = {prototype = {}}
c.prototype.__index = c.prototype
c.prototype.constructor = c
return c
end
local ____exports = {}
____exports.Vector2 = __TS__Class()
local Vector2 = ____exports.Vector2
Vector2.name = "Vector2"
function Vector2.prototype.____constructor(self, x, y)
self.x = x
self.y = y
end
return ____exports
end)
b334c[13] = r334c(13, function()
local function __TS__New(target, ...)
local instance = setmetatable({}, target.prototype)
instance:____constructor(...)
return instance
end
local ____exports = {}
local ____card = b334c[17]('game_src_game_entities_card')
local Card = ____card.Card
function ____exports.createCardInstance(card)
local cardInfo = {
id = card.id,
name = card.name,
texture = card.texture,
value = card.value,
is_special = card.is_special,
special_effect = card.special_effect
}
return __TS__New(Card, cardInfo)
end
return ____exports
end)
b334c[14] = r334c(14, function()
local function __TS__Class(self)
local c = {prototype = {}}
c.prototype.__index = c.prototype
c.prototype.constructor = c
return c
end
local function __TS__New(target, ...)
local instance = setmetatable({}, target.prototype)
instance:____constructor(...)
return instance
end
local function __TS__ArrayForEach(self, callbackFn, thisArg)
for i = 1, #self do
callbackFn(thisArg, self[i], i - 1, self)
end
end
local function __TS__ArrayFindIndex(self, callbackFn, thisArg)
for i = 1, #self do
if callbackFn(thisArg, self[i], i - 1, self) then
return i - 1
end
end
return -1
end
local function __TS__CountVarargs(...)
return select("#", ...)
end
local function __TS__ArraySplice(self, ...)
local args = {...}
local len = #self
local actualArgumentCount = __TS__CountVarargs(...)
local start = args[1]
local deleteCount = args[2]
if start < 0 then
start = len + start
if start < 0 then
start = 0
end
elseif start > len then
start = len
end
local itemCount = actualArgumentCount - 2
if itemCount < 0 then
itemCount = 0
end
local actualDeleteCount
if actualArgumentCount == 0 then
actualDeleteCount = 0
elseif actualArgumentCount == 1 then
actualDeleteCount = len - start
else
actualDeleteCount = deleteCount or 0
if actualDeleteCount < 0 then
actualDeleteCount = 0
end
if actualDeleteCount > len - start then
actualDeleteCount = len - start
end
end
local out = {}
for k = 1, actualDeleteCount do
local from = start + k
if self[from] ~= nil then
out[k] = self[from]
end
end
if itemCount < actualDeleteCount then
for k = start + 1, len - actualDeleteCount do
local from = k + actualDeleteCount
local to = k + itemCount
if self[from] then
self[to] = self[from]
else
self[to] = nil
end
end
for k = len - actualDeleteCount + itemCount + 1, len do
self[k] = nil
end
elseif itemCount > actualDeleteCount then
for k = len - actualDeleteCount, start + 1, -1 do
local from = k + actualDeleteCount
local to = k + itemCount
if self[from] then
self[to] = self[from]
else
self[to] = nil
end
end
end
local j = start + 1
for i = 3, actualArgumentCount do
self[j] = args[i]
j = j + 1
end
for k = #self, len - actualDeleteCount + itemCount + 1, -1 do
self[k] = nil
end
return out
end
local ____exports = {}
local ____vector2 = b334c[12]('game_src_core_spatial_vector2')
local Vector2 = ____vector2.Vector2
local ____card = b334c[17]('game_src_game_entities_card')
local Card = ____card.Card
local ____GameConfig = b334c[3]('game_src_game_config_GameConfig')
local GameConfig = ____GameConfig.GameConfig
____exports.Hand = __TS__Class()
local Hand = ____exports.Hand
Hand.name = "Hand"
function Hand.prototype.____constructor(self)
self.cards = {}
self.upgrades = {}
self.selectedCard = 0
self.cardsQuantity = GameConfig.HAND_SIZE
end
function Hand.prototype.generateNewHand(self, deck)
print("# Generating New Hand #")
local newCard = nil
do
local i = 0
while i < self.cardsQuantity do
newCard = self:getNewCard(deck)
print("Get card with success:", newCard)
local cardCount = 0
do
local n = 0
while n < #self.cards do
if cardCount == 2 then
break
end
local card = self.cards[n + 1]
if card.id == newCard.id then
cardCount = cardCount + 1
end
n = n + 1
end
end
if cardCount >= 2 then
local reserveCard = self:getNewCard(deck)
while newCard.id == reserveCard.id do
reserveCard = self:getNewCard(deck)
end
local ____self_cards_0 = self.cards
____self_cards_0[#____self_cards_0 + 1] = reserveCard
else
local ____self_cards_1 = self.cards
____self_cards_1[#____self_cards_1 + 1] = newCard
end
i = i + 1
end
end
print("Finished generating new hand!")
end
function Hand.prototype.getNewCard(self, deck)
print("Generating Card...")
return __TS__New(
Card,
deck[math.floor(math.random() * #deck) + 1]
)
end
function Hand.prototype.drawHandCards(self, std, hide)
if hide == nil then
hide = false
end
__TS__ArrayForEach(
self.cards,
function(____, card)
card:drawCard(std, hide)
end
)
end
function Hand.prototype.updateState(self, std)
__TS__ArrayForEach(
self.cards,
function(____, card)
card:update(std)
end
)
end
function Hand.prototype.setCardsPosition(self, screenWidth, screenHeight)
local spacing = 20
local cardWidth = 71
local cardHeight = 100
local totalWidth = #self.cards * spacing + (#self.cards - 1) * cardWidth
local x = (screenWidth - totalWidth) / 2
__TS__ArrayForEach(
self.cards,
function(____, card)
card.transform.position = __TS__New(Vector2, x, screenHeight - cardHeight - spacing * 2)
x = x + (cardWidth + spacing)
end
)
end
function Hand.prototype.switchActiveCard(self, sum)
if sum then
if self.selectedCard < #self.cards - 1 then
self.selectedCard = self.selectedCard + 1
self.cards[self.selectedCard + 1]:up()
do
local i = 0
while i < #self.cards do
local card = self.cards[i + 1]
if i ~= self.selectedCard then
card:down()
end
i = i + 1
end
end
end
else
if self.selectedCard >= 1 then
self.selectedCard = self.selectedCard - 1
self.cards[self.selectedCard + 1]:up()
do
local i = 0
while i < #self.cards do
local card = self.cards[i + 1]
if i ~= self.selectedCard then
card:down()
end
i = i + 1
end
end
end
end
end
function Hand.prototype.getSelectedCard(self)
return self.cards[self.selectedCard + 1]
end
function Hand.prototype.setSelectedCard(self, index)
if index >= 0 and index < #self.cards - 1 then
self.selectedCard = index
else
print("Invalid card index")
end
end
function Hand.prototype.getAllCards(self)
return self.cards
end
function Hand.prototype.addNewUpgrade(self, upgrade)
local ____self_upgrades_2 = self.upgrades
____self_upgrades_2[#____self_upgrades_2 + 1] = upgrade
end
function Hand.prototype.removeCardById(self, id)
local index = __TS__ArrayFindIndex(
self.cards,
function(____, card) return card.id == id end
)
if index ~= -1 then
__TS__ArraySplice(self.cards, index, 1)
end
end
function Hand.prototype.use(self)
end
return ____exports
end)
b334c[15] = r334c(15, function()
local function __TS__Class(self)
local c = {prototype = {}}
c.prototype.__index = c.prototype
c.prototype.constructor = c
return c
end
local function __TS__New(target, ...)
local instance = setmetatable({}, target.prototype)
instance:____constructor(...)
return instance
end
local ____exports = {}
local ____upgradeCard = b334c[18]('game_src_game_upgrades_upgradeCard')
local UpgradeCard = ____upgradeCard.UpgradeCard
____exports.UpgradeDeck = __TS__Class()
local UpgradeDeck = ____exports.UpgradeDeck
UpgradeDeck.name = "UpgradeDeck"
function UpgradeDeck.prototype.____constructor(self, deck)
self.upgrades = {}
self.deck = deck
end
function UpgradeDeck.prototype.getNewCard(self, deck)
print("Generating UpgradeCard...")
return __TS__New(
UpgradeCard,
deck[math.floor(math.random() * #deck) + 1]
)
end
function UpgradeDeck.prototype.generateNewUpgrades(self, cardsQuantity)
print("# Generating New Hand #")
self.upgrades = {}
local newCard = nil
do
local i = 0
while i < cardsQuantity do
newCard = self:getNewCard(self.deck)
print("Get card with success:", newCard)
local cardCount = 0
do
local n = 0
while n < #self.upgrades do
if cardCount > 0 then
break
end
local card = self.upgrades[n + 1]
if card.id == newCard.id then
cardCount = cardCount + 1
end
n = n + 1
end
end
if cardCount > 0 then
local reserveCard = self:getNewCard(self.deck)
while newCard.id == reserveCard.id do
reserveCard = self:getNewCard(self.deck)
end
local ____self_upgrades_0 = self.upgrades
____self_upgrades_0[#____self_upgrades_0 + 1] = reserveCard
else
local ____self_upgrades_1 = self.upgrades
____self_upgrades_1[#____self_upgrades_1 + 1] = newCard
end
i = i + 1
end
end
print("Finished generating new hand!")
end
function UpgradeDeck.prototype.getUpgradeCards(self)
return self.upgrades
end
return ____exports
end)
b334c[16] = r334c(16, function()
local ____exports = {}
____exports.UPGRADE_CARD_LIST = {{id = "combo_naipes", name = "Combo de Naipe", texture = "card1.png", special_effect = 1}, {id = "eco_inverso", name = "Eco Inverso", texture = "card2.png", special_effect = 2}, {id = "baralho_ensanguentado", name = "Baralho Ensanguentado", texture = "card3.png", special_effect = 3}}
return ____exports
end)
b334c[17] = r334c(17, function()
local function __TS__Class(self)
local c = {prototype = {}}
c.prototype.__index = c.prototype
c.prototype.constructor = c
return c
end
local function __TS__ClassExtends(target, base)
target.____super = base
local staticMetatable = setmetatable({__index = base}, base)
setmetatable(target, staticMetatable)
local baseMetatable = getmetatable(base)
if baseMetatable then
if type(baseMetatable.__index) == "function" then
staticMetatable.__index = baseMetatable.__index
end
if type(baseMetatable.__newindex) == "function" then
staticMetatable.__newindex = baseMetatable.__newindex
end
end
setmetatable(target.prototype, base.prototype)
if type(base.prototype.__index) == "function" then
target.prototype.__index = base.prototype.__index
end
if type(base.prototype.__newindex) == "function" then
target.prototype.__newindex = base.prototype.__newindex
end
if type(base.prototype.__tostring) == "function" then
target.prototype.__tostring = base.prototype.__tostring
end
end
local function __TS__New(target, ...)
local instance = setmetatable({}, target.prototype)
instance:____constructor(...)
return instance
end
local ____exports = {}
local ____vector2 = b334c[12]('game_src_core_spatial_vector2')
local Vector2 = ____vector2.Vector2
local ____gameObject = b334c[19]('game_src_game_entities_gameObject')
local GameObject = ____gameObject.GameObject
____exports.Card = __TS__Class()
local Card = ____exports.Card
Card.name = "Card"
__TS__ClassExtends(Card, GameObject)
function Card.prototype.____constructor(self, cardInfo)
GameObject.prototype.____constructor(
self,
__TS__New(Vector2, 100, 100),
__TS__New(Vector2, 100, 100)
)
self.isUp = false
self.id = cardInfo.id
self.name = cardInfo.name
self.texture = cardInfo.texture
self.value = cardInfo.value
self.is_special = cardInfo.is_special
self.special_effect = cardInfo.special_effect
end
function Card.prototype.up(self)
print("card up")
self:start({x = self.transform.position.x, y = self.transform.position.y - 50}, 0.5)
self.isUp = true
end
function Card.prototype.down(self)
if not self.isUp then
return
end
print("card down")
self:start({x = self.transform.position.x, y = self.transform.position.y + 50}, 0.5)
self.isUp = false
end
function Card.prototype.drawCard(self, std, hide)
if hide == nil then
hide = false
end
if hide then
std.image.draw("https://raw.githubusercontent.com/AlexOliveiraaDev/cardgame-glyengine/refs/heads/main/src/game/assets/cards/Card_2.png", self.transform.position.x, self.transform.position.y)
else
std.image.draw("https://raw.githubusercontent.com/AlexOliveiraaDev/cardgame-glyengine/refs/heads/main/src/game/assets/cards/" .. self.texture, self.transform.position.x, self.transform.position.y)
end
end
function Card.prototype.damage(self, std)
local time = 0
local originalTexture = tostring(self.texture)
self.texture = "card_damage.png"
while time < 2 do
self:drawCard(std)
print("time", time)
time = time + std.delta / 1000
print("texture", self.texture)
end
print("finished damage")
self.texture = originalTexture
end
function Card.prototype.testDamage(self, std)
std.image.draw("https://raw.githubusercontent.com/AlexOliveiraaDev/cardgame-glyengine/refs/heads/main/src/game/assets/cards/card_damage.png", self.transform.position.x, self.transform.position.y)
end
return ____exports
end)
b334c[18] = r334c(18, function()
local function __TS__Class(self)
local c = {prototype = {}}
c.prototype.__index = c.prototype
c.prototype.constructor = c
return c
end
local function __TS__ClassExtends(target, base)
target.____super = base
local staticMetatable = setmetatable({__index = base}, base)
setmetatable(target, staticMetatable)
local baseMetatable = getmetatable(base)
if baseMetatable then
if type(baseMetatable.__index) == "function" then
staticMetatable.__index = baseMetatable.__index
end
if type(baseMetatable.__newindex) == "function" then
staticMetatable.__newindex = baseMetatable.__newindex
end
end
setmetatable(target.prototype, base.prototype)
if type(base.prototype.__index) == "function" then
target.prototype.__index = base.prototype.__index
end
if type(base.prototype.__newindex) == "function" then
target.prototype.__newindex = base.prototype.__newindex
end
if type(base.prototype.__tostring) == "function" then
target.prototype.__tostring = base.prototype.__tostring
end
end
local function __TS__New(target, ...)
local instance = setmetatable({}, target.prototype)
instance:____constructor(...)
return instance
end
local ____exports = {}
local ____vector2 = b334c[12]('game_src_core_spatial_vector2')
local Vector2 = ____vector2.Vector2
local ____gameObject = b334c[19]('game_src_game_entities_gameObject')
local GameObject = ____gameObject.GameObject
____exports.UpgradeCard = __TS__Class()
local UpgradeCard = ____exports.UpgradeCard
UpgradeCard.name = "UpgradeCard"
__TS__ClassExtends(UpgradeCard, GameObject)
function UpgradeCard.prototype.____constructor(self, cardInfo)
GameObject.prototype.____constructor(
self,
__TS__New(Vector2, 100, 100),
__TS__New(Vector2, 100, 100)
)
self.isUp = false
self.id = cardInfo.id
self.name = cardInfo.name
self.texture = cardInfo.texture
self.special_effect = cardInfo.special_effect
end
function UpgradeCard.prototype.up(self)
print("card up")
self:start({x = self.transform.position.x, y = self.transform.position.y - 50}, 0.5)
self.isUp = true
end
function UpgradeCard.prototype.down(self)
if not self.isUp then
return
end
print("card down")
self:start({x = self.transform.position.x, y = self.transform.position.y + 50}, 0.5)
self.isUp = false
end
function UpgradeCard.prototype.drawCard(self, std)
std.image.draw("https://raw.githubusercontent.com/AlexOliveiraaDev/cardgame-glyengine/refs/heads/main/src/game/assets/cards/" .. self.texture, self.transform.position.x, self.transform.position.y)
end
return ____exports
end)
b334c[19] = r334c(19, function()
local function __TS__Class(self)
local c = {prototype = {}}
c.prototype.__index = c.prototype
c.prototype.constructor = c
return c
end
local function __TS__New(target, ...)
local instance = setmetatable({}, target.prototype)
instance:____constructor(...)
return instance
end
local ____exports = {}
local ____transform = b334c[20]('game_src_core_spatial_transform')
local Transform = ____transform.Transform
local ____animationController = b334c[21]('game_src_core_animation_animationController')
local AnimationController = ____animationController.AnimationController
____exports.GameObject = __TS__Class()
local GameObject = ____exports.GameObject
GameObject.name = "GameObject"
function GameObject.prototype.____constructor(self, position, scale)
self.transform = __TS__New(Transform, position, scale)
self.animator = __TS__New(AnimationController, self)
end
function GameObject.prototype.draw(self, std)
std.draw.rect(
0,
self.transform.position.x,
self.transform.position.y,
self.transform.scale.x,
self.transform.scale.y
)
end
function GameObject.prototype.update(self, dt)
self.animator:update(dt.delta)
end
function GameObject.prototype.start(self, position, duration)
self.animator:start(position, duration)
end
return ____exports
end)
b334c[20] = r334c(20, function()
local function __TS__Class(self)
local c = {prototype = {}}
c.prototype.__index = c.prototype
c.prototype.constructor = c
return c
end
local ____exports = {}
____exports.Transform = __TS__Class()
local Transform = ____exports.Transform
Transform.name = "Transform"
function Transform.prototype.____constructor(self, position, scale)
self.position = position
self.scale = scale
end
return ____exports
end)
b334c[21] = r334c(21, function()
local function __TS__Class(self)
local c = {prototype = {}}
c.prototype.__index = c.prototype
c.prototype.constructor = c
return c
end
local ____exports = {}
____exports.AnimationController = __TS__Class()
local AnimationController = ____exports.AnimationController
AnimationController.name = "AnimationController"
function AnimationController.prototype.____constructor(self, obj)
self.obj = obj
self.active = false
self.duration = 0
self.elapsed = 0
end
function AnimationController.prototype.start(self, position, duration)
self.startPosition = self.obj.transform.position
self.endPosition = position
self.duration = duration
self.elapsed = 0
self.active = true
end
function AnimationController.prototype.update(self, dt)
if not self.active then
return
end
self.elapsed = self.elapsed + dt / 1000
local t = math.min(self.elapsed / self.duration, 1)
local easedT = 1 - (1 - t) ^ 5
local newX = self.startPosition.x + (self.endPosition.x - self.startPosition.x) * easedT
local newY = self.startPosition.y + (self.endPosition.y - self.startPosition.y) * easedT
self.obj.transform.position.x = newX
self.obj.transform.position.y = newY
if easedT >= 1 then
self.active = false
self.obj.transform.position.x = self.endPosition.x
self.obj.transform.position.y = self.endPosition.y
end
end
return ____exports
end)
return m334c()
