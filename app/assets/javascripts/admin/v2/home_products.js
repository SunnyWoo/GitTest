$(document).on('page:change', function () {
    var name_formatter = function (item) {
        if (item.model) {
            return "<li><p>" + item.name + " - " + item.model + "</p></li>"
        } else {
            return "<li><p>" + item.name + "</p></li>"
        }
    };

    $(".ids_input_token").each(function () {
        $(this).tokenInput(
            'home_products/work_names.json',
            {
                theme: "facebook",
                preventDuplicates: true,
                prePopulate: [
                    {id: $(this).data("id"), name: $(this).data("name"), model: $(this).data("model")}
                ],
                resultsFormatter: function (item) {
                    return "<li>" + "<img src='" + item.remote_cover_image_url + "' height='25px' width='25px' />" + "<div style='display: inline-block; padding-left: 10px;'><div class='work_name'>" + item.name + "</div><div class='work_model'>" + item.model + "</div></div></li>"
                },
                tokenFormatter: function (item) {
                    return name_formatter(item)
                },
                onAdd: function (item) {
                    if ($(this).tokenInput("get").length > 1) {
                        $(this).tokenInput("remove", $(this).tokenInput("get")[0]);
                    }
                }
            }
        );
    })
});