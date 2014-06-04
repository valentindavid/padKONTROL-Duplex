duplex_configurations:insert {
  name = "Blank",
  pinned = true,

  device = {
    class_name = "padKONTROL",          
    display_name = "padKONTROL",
    device_port_in = "padKONTROL",
    device_port_out = "padKONTROL",
    control_map = "Controllers/padKONTROL/Controlmaps/padKONTROL.xml",
    protocol = DEVICE_PROTOCOL.MIDI
  },
  
  applications = {
    SwitchConfiguration = {
      mappings = {
        goto_previous = {
          group_name = "Setting",
          index = 4,
        },
        goto_next = {
          group_name = "Setting",
          index = 5,
        },
      }
    },
  }
}
