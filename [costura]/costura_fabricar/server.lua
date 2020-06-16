local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")
func = {}
Tunnel.bindInterface("costura_fabricar",func)
-----------------------------------------------------------------------------------------------------------------------------------------
-- FUNÇÕES
-----------------------------------------------------------------------------------------------------------------------------------------
function func.checkPermission()
	local source = source
	local user_id = vRP.getUserId(source)
	return vRP.hasPermission(user_id,"costura.permissao")
end

RegisterServerEvent("costura-comprar")
AddEventHandler("costura-comprar",function(item)
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		for k,v in pairs(Config.valores) do
			if item == v.item then

				local tempo = 0
				local isArma = false
				if v.componentes then
					for k2,v2 in pairs(v.componentes) do -- VERIFICA SE TEM TODOS OS ITTENS
						if vRP.getInventoryItemAmount(user_id, v2.componente) >= v2.qtd then
							tempo = tempo+v2.qtd
						else
							TriggerClientEvent("Notify",source,"negado","Você não possui "..vRP.getItemName(v2.componente).." suficiente!")
							return false
						end
					end
					for k2,v2 in pairs(v.componentes) do -- SE TEM TODOS OS ITENS, TIRA ELES DO INVENTARIO
						vRP.tryGetInventoryItem(user_id, v2.componente, v2.qtd)
					end
					
				else
					tempo = 10
					
				end

				if vRP.getInventoryWeight(user_id)+vRP.getItemWeight(v.item)*v.qtd <= vRP.getInventoryMaxWeight(user_id) then

						TriggerClientEvent("costura_fabricar:fecharMenu", source)
						TriggerClientEvent("progress",source,tempo*1000,"COSTURANDO")
                  				TriggerClientEvent("costura_fabricar:animacao",source, true)

						Citizen.Wait(tempo*1000)
						TriggerClientEvent("costura_fabricar:animacao",source, false)
						
				else
					TriggerClientEvent("Notify",source,"negado","Espaço insuficiente.")
				end
			end
		end
	end
end)

RegisterCommand('use',function(source,args,rawCommand)
	if args[1] == nil then
		return
   end
	local user_id = vRP.getUserId(source)
	if args[1] == "colete" then
		if vRP.tryGetInventoryItem(user_id,"colete",1) then
         vRPclient.setArmour(source,100)
			TriggerClientEvent("Notify",source,"sucesso","Colete Equipado com sucesso.")
		else
			TriggerClientEvent("Notify",source,"negado","Colete não encontrado na mochila.")
      end
   elseif args[1] == "mochila" then
		if vRP.tryGetInventoryItem(user_id,"mochila",1) then
			vRP.varyExp(user_id,"physical","strength", 650)
			TriggerClientEvent("Notify",source,"sucesso","Mochila utilizada com sucesso.")
		else
			TriggerClientEvent("Notify",source,"negado","Mochila não encontrada na mochila.")
      end
	end
end)
