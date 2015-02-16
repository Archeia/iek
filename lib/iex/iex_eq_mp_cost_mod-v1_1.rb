#==============================================================================#
# ** IEX(Icy Engine Xelion) - Equipment Mp Mod
#------------------------------------------------------------------------------#
# ** Created by    : IceDragon
# ** Script-Status : Addon (Skills Mp)
# ** Script Type   : Skill Mp Cost Modifier
# ** Date Created  : 11/07/2010
# ** Date Modified : 07/24/2011
# ** Version       : 1.1
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INTRODUCTION
#------------------------------------------------------------------------------#
# This script adds the ability to have a MP mod for skills from equipment.
# Therefore you can have a sword that makes skills only cost 25% of there
# original mp cost.
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** FEATURES
#------------------------------------------------------------------------------#
# V1.0
#  Notetags! Placed in Equipment noteboxes
#------------------------------------------------------------------------------#
# <MP_COST_MOD: x%> or <mp cost mod: x%>
# 100% - No change
# <100%- Lower Cost
# >100%- Increase Cost
#
# EG.
# <mp cost mod: 110%>
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** COMPATABLITIES
#------------------------------------------------------------------------------#
#  IS NOT COMPATABLE WITH BEM (Battle Engine Melody)
#  Don't even bother trying.
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGE LOG
#------------------------------------------------------------------------------#
#
# (DD/MM/YYYY)
#  11/07/2010 - V1.0  Finished Script
#  07/24/2011 - V1.1  Edited for the IEX Recall
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** KNOWN ISSUES
#------------------------------------------------------------------------------#
#  Non at the moment.
#
#------------------------------------------------------------------------------#
$imported ||= {}
$imported["IEX_Equip_MP_Mod"] = true
#==============================================================================#
# ** IEX::REGEXP::EQUIP_MP_MOD
#==============================================================================#
module IEX
  module REGEXP
    module EQUIP_MP_MOD
      MP_MOD = /<(?:MP_COST_MOD|mp cost mod):[ ]*(\d+)([%%])>/i
    end
  end
end

#==============================================================================#
# ** RPG::BaseItem
#==============================================================================#
class RPG::BaseItem
  #--------------------------------------------------------------------------#
  # * new-method :iex_mp_mod_bi_cache
  #--------------------------------------------------------------------------#
  def iex_mp_mod_bi_cache
    @iex_mp_mod = 100
    self.note.split(/[\r\n]+/).each do |line|
      case line
      when IEX::REGEXP::EQUIP_MP_MOD::MP_MOD
        @iex_mp_mod = $1.to_i
      end
    end
  end

  #--------------------------------------------------------------------------#
  # * new-method :iex_equip_mp_mod
  #--------------------------------------------------------------------------#
  def iex_equip_mp_mod
    iex_mp_mod_bi_cache if @iex_mp_mod.nil?
    return @iex_mp_mod
  end
end

#==============================================================================#
# ** Game_Battler
#==============================================================================#
class Game_Battler
  #--------------------------------------------------------------------------#
  # * new-method :iex_calc_equipment_mp_mod
  #--------------------------------------------------------------------------#
  def iex_calc_equipment_mp_mod( cost ) ; return cost ; end

  #--------------------------------------------------------------------------#
  # * alias-method :calc_mp_cost
  #--------------------------------------------------------------------------#
  alias :iex_equip_mp_cost_mod_calc_mp_cost :calc_mp_cost unless $@
  def calc_mp_cost( *args, &block )
    icost = iex_equip_mp_cost_mod_calc_mp_cost( *args, &block )
    icost = iex_calc_equipment_mp_mod( icost )
    return Integer( icost )
  end
end

#==============================================================================#
# ** Game_Actor
#==============================================================================#
class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------#
  # * overwrite-method :iex_calc_equipment_mp_mod
  #--------------------------------------------------------------------------#
  def iex_calc_equipment_mp_mod(cost)
    equips.compact.inject(cost) do |ncost, eq|
      ncost * eq.iex_equip_mp_mod / 100.0
    end.to_i
  end
end

#==============================================================================#
# ** END OF FILE
#==============================================================================#