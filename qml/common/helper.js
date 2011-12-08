.pragma library

function switch_locations(from, to) {
    var templo = from.text
    var tempcoord = from.destination_coords
    var tempindex = from.selected_favorite

    if(from.destination_coords != '') {
        to.auto_update = true
    }
    if(to.destination_coords != '') {
        from.auto_update = true
    }
    from.model.clear()
    from.destination_coords = to.destination_coords
    from.text = to.text
    from.selected_favorite = to.selected_favorite

    to.model.clear()
    to.destination_coords = tempcoord
    to.text = templo
    to.selected_favorite = tempindex
}

function parse_disruption_time(time) {
        var newtime = time;
        return new Date(newtime.slice(0,4),
                        parseInt(newtime.slice(5,7),10) - 1,
                        newtime.slice(8,10),
                        newtime.slice(11,13),
                        newtime.slice(14,16),
                        00, 00);
}
