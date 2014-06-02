class 'Constant' (Application)

Constant.default_options = {
}
Constant.available_mappings = {
   control = {
      description = "Group to set",
   }
}
Constant.default_palette = {
}

function Constant:__init(...)
   Application.__init(self,...)
end

function Constant:_build_app()
  local c = UILabel(self)

  c.group_name = self.mappings.control.group_name
  c:set_pos(self.mappings.control.index)
  c.tooltip = self.mappings.control.description
  self:_add_component(c)
  self.control = c
  c:set_text(self.mappings.control.value)

  return true
end
