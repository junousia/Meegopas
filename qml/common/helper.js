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
