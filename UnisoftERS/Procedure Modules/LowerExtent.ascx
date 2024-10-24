<%@ Control Language="vb" AutoEventWireup="false" CodeBehind="LowerExtent.ascx.vb" Inherits="UnisoftERS.LowerExtent" %>

<style type="text/css">
    table td {
        vertical-align: top;
    }

    .uncessful-extext-options {
        width: 50% !important;
    }

        .uncessful-extext-options td {
            width: 33%;
            width: 33%;
        }

    .rfdInputDisabled, .riDisabled {
        opacity: 0.4 !important;
    }

    .identifiedby-child {
        position: absolute;
        margin-left: 10px;
    }

    .OtherLimitation, .OtherInsertionConfirmed, .otherDifficulties {
        display: none;
    }
</style>
<telerik:RadScriptBlock runat="server">
    <script type="text/javascript">
        var autoSaveSuccess;
        var confirmByOther = false;
        var limitationByOther = false;
        var difficultyOtherShow = false;
        var ceecumCheckBox = false;
        $(window).on('load', function () {
            toggleLowerLimitation();
            toggleNoRetroflexionReason();
            toggleLowerInsertionConfirmed();
            toggleLowerDifficulty();
            //this must be done last as it hides and shows based on outome of the extent success
            toggleLowerControls();
            //Added by rony tfs-2830
            toggleLowerExtentChangedControls();
        });

        $(document).ready(function () {
   
            $('.cb-retroflexion-reason').on('focusout', function () {
                var endoscopistId = $(this).attr("data-endoscopistid");
                saveLowerExtentData(endoscopistId);
            });
            $('.auto-save-control').on('change', function () {
                var endoscopistId = $(this).attr("data-endoscopistid");
                saveLowerExtentData(endoscopistId);
            });

            $('.other-confirmed-by-entry').on('focusout', function () {
                var endoscopistId = $(this).attr("data-endoscopistid");
                saveLowerExtentData(endoscopistId);
            });

            $('.other-limitation-entry').on('focusout', function () {
                var endoscopistId = $(this).attr("data-endoscopistid");
                saveLowerExtentData(endoscopistId);
            });

            $('.other-difficulty-entry').on('focusout', function () {
                var endoscopistId = $(this).attr("data-endoscopistid");
                saveLowerExtentData(endoscopistId);
            });

            $('.failed-lower-options input').on('change', function (e) {
                $('.cb-lowerextent').each(function (idx, itm) { //must save against all endoscopist
                    var endoscopistId = $(this).attr("data-endoscopistid");
                    toggleLowerControls();
                    saveLowerExtentData(endoscopistId);

                });
            });

            $('.identifiedby-parent input').on('change', function () {
                ceecumCheckBox = true;
                var childControl = $(this).closest('td').find('.identifiedby-child');
                if (childControl.length > 0) {
                    if ($(this).is(':checked')) {
                        $(childControl).show();
                        $(childControl).css('display', 'inline-block');
                    }
                    else {
                        $(childControl).hide();
                        var comboBox = $find(childControl.attr('id'));
                        if (comboBox) {
                            comboBox.clearSelection();
                        }
                    }
                }
                //auto save
                var id = $(this).closest('td').find('.identifiedby-parent').attr('data-uniqueid');
                var endoId = $(this).closest('td').find('.identifiedby-parent').attr('data-endoscopistid');
                var checked = $(this).is(':checked');

                saveData(id, 0, endoId, checked);
            });

            $('[cb-retroflexion]').each(function (idx, itm) {
                var endoId = $(this).attr('data-endoscopistid');
                $('.cb-retroflexion-reason[data-endoscopistid="' + endoId + '"]').hide();
            });

        });
  

        function lower_extent_changed(sender, args) {
            //toggleLowerControls(); //toggle before showing so hidden dropdowns are set to 0 for DB saving
            resetLowerControls();
            saveLowerExtent(sender, args);
            //Added by rony tfs-2830
            $('.cb-lowerextent').each(function (idx, itm) {
                var plannedExtentVal = $("#PlannedExtentComboBoxInput").val();
                var ctrl = $find($(itm)[0].id);
                var selectedItem = ctrl.get_selectedItem();
                var listOrderById = selectedItem.get_attributes().getAttribute("data-lower-extent")

                //if (parseInt(listOrderById) >= parseInt(plannedExtentVal) || listOrderById === undefined) {
                //    $(itm).closest('.lower-extent-options').find('tr.InsertionLimitedTr').hide();
                //    $(itm).closest('.lower-extent-options').find('tr.DifficultiesEncounteredTr').hide();
                //} else {
                //    $(itm).closest('.lower-extent-options').find('tr.InsertionLimitedTr').show();
                //    $(itm).closest('.lower-extent-options').find('tr.DifficultiesEncounteredTr').show();
                //}
            });
        }
        //Added by rony tfs-2830
        function toggleLowerExtentChangedControls() {
            $('.cb-lowerextent').each(function (idx, itm) { 
                var plannedExtentVal = $("#PlannedExtentComboBoxInput").val();
                var ctrl = $find($(itm)[0].id);
                var selectedItem = ctrl.get_selectedItem();
                var listOrderById = selectedItem.get_attributes().getAttribute("data-lower-extent")

                //if (parseInt(listOrderById) >= parseInt(plannedExtentVal) || listOrderById === undefined) {
                //    $(itm).closest('.lower-extent-options').find('tr.InsertionLimitedTr').hide();
                //    $(itm).closest('.lower-extent-options').find('tr.DifficultiesEncounteredTr').hide();
                //} else {
                //    $(itm).closest('.lower-extent-options').find('tr.InsertionLimitedTr').show();
                //    $(itm).closest('.lower-extent-options').find('tr.DifficultiesEncounteredTr').show();
                //}
            });
        }
        //Added by rony tfs-2830
        function resetLowerExtent() {
            $('.cb-lowerextent').each(function (idx, itm) {
                $(".resetLowerExtent input").val("");
                var endoscopistId = $(this).attr("data-endoscopistid");
                $(itm).closest('.lower-extent-options').find('tr.InsertionLimitedTr').hide();
                $(itm).closest('.lower-extent-options').find('tr.DifficultiesEncounteredTr').hide();


                var rectalExamDone = $('.cb-prdone[data-endoscopistid="' + endoscopistId + '"]');
                var retroflexion = $('.cb-retroflexion[data-endoscopistid="' + endoscopistId + '"]');
                var noRetroflexionReason = $('.cb-retroflexion-reason[data-endoscopistid="' + endoscopistId + '"]');
                var insertionVia = $('.cb-insertionvia[data-endoscopistid="' + endoscopistId + '"]');
                var extentId = $('.cb-lowerextent[data-endoscopistid="' + endoscopistId + '"]');
                var confirmedBy = $('.cb-insertionconfirmed[data-endoscopistid="' + endoscopistId + '"]');
                var confirmedByOther = $('.other-confirmed-by-entry[data-endoscopistid="' + endoscopistId + '"]');
                var caecumIdentifiedById = $('.cb-caecumidentifiedby[data-endoscopistid="' + endoscopistId + '"]');
                var limitationId = $('.cb-limitation[data-endoscopistid="' + endoscopistId + '"]');
                var limitationOther = $('.other-limitation-entry[data-endoscopistid="' + endoscopistId + '"]');
                var difficultyId = $('.cb-difficulties[data-endoscopistid="' + endoscopistId + '"]');
                var difficultyOther = $('.other-difficulty-entry[data-endoscopistid="' + endoscopistId + '"]');
                var abandoned = $('.failed-lower-options[data-failuretype="abandoned"] input');
                var intubationFailed = $('.failed-lower-options[data-failuretype="intubationfailed"] input');

                var obj = {};
                if ($('.failed-lower-options input').is(':checked')) {
                    obj.abandoned = $(abandoned).is(':checked');
                    obj.intubationFailed = $(intubationFailed).is(':checked');
                }
                else {
                    obj.abandoned = false;
                    obj.intubationFailed = false;
                }
                obj.procedureId = parseInt(<%= Session(UnisoftERS.Constants.SESSION_PROCEDURE_ID)%>);
                obj.rectalExam = (rectalExamDone.length == 0) ? -1 : parseInt($find($(rectalExamDone)[0].id).get_value());
                obj.retroflexion = (retroflexion.length == 0) ? -1 : parseInt($find($(retroflexion)[0].id).get_value());
                obj.noRetroflexionReason = ($(noRetroflexionReason).length == 0) ? '' : $(noRetroflexionReason).val();
                obj.insertionVia = (insertionVia.length == 0) ? 0 : parseInt($find($(insertionVia)[0].id).get_value());
                obj.confirmedById = (confirmedBy.length == 0) ? 0 : $find($(confirmedBy)[0].id).get_value();
                obj.confirmedByOther = ($(confirmedByOther).length == 0) ? '' : $(confirmedByOther).val(); //otherText;
                obj.caecumIdentifiedById = 0; //this needs removing from the DB!! then can remove from here
                obj.extentId = 0;
                obj.limitationId = 0;
                obj.limitationOther = ($(limitationOther).length == 0) ? '' : $(limitationOther).val(); //otherText;
                obj.difficultyId = (difficultyId.length == 0) ? 0 : $find($(difficultyId)[0].id).get_value();
                obj.difficultyOther = ($(difficultyOther).length == 0) ? '' : $(difficultyOther).val(); //otherText;
                obj.additionalInfo = '';
                obj.endoscopistId = endoscopistId;
                if (obj.retroflexion == 0) {
                    $(`#RetroflexionCancellationReason_${endoscopistId}`).show();
                }
                else {
                    $(`#RetroflexionCancellationReason_${endoscopistId}`).hide();
                    obj.noRetroflexionReason = "";
                    $(noRetroflexionReason).val("");
                }
                $.ajax({
                    type: "POST",
                    url: "../Procedure.aspx/saveLowerExtent",
                    data: JSON.stringify(obj),
                    dataType: "json",
                    contentType: "application/json; charset=utf-8",
                    success: function () {
                        if ($('.failed-lower-options input').is(':checked')) {
                            ////update timings and call their save method
                            //updateCaecumTimings(0);
                            //saveWithdrawalTime(0);
                        }
                        setRehideSummary();
                    },
                    error: function (x, y, z) {

                        autoSaveSuccess = false;
                        //show a message
                        var objError = x.responseJSON;
                        var errorString = buildErrorString(objError.Message, 'There was an error saving your data.');

                        $find('<%=RadNotification1.ClientID%>').set_text(errorString);
                        $find('<%=RadNotification1.ClientID%>').show();

                    }
                });
                
            });
        }
     

        function saveData(id, childId, endoscopistId, checked) {
            var obj = {};
            obj.identifiedById = parseInt(id);
            obj.childId = parseInt(childId);
            obj.procedureId = parseInt(<%= Session(UnisoftERS.Constants.SESSION_PROCEDURE_ID)%>);
            obj.endoscopistId = parseInt(endoscopistId);
            obj.checked = checked;

            $.ajax({
                type: "POST",
                url: "../Procedure.aspx/saveCaecumIdentifiedBy",
                data: JSON.stringify(obj),
                dataType: "json",
                contentType: "application/json; charset=utf-8",
                success: function (data) {
                    saveLowerExtentData(endoscopistId); //we need to call this to update the summary report
                    setRehideSummary();
                },
                error: function (x, y, z) {
                    //show a message
                    var objError = x.responseJSON;
                    var errorString = buildErrorString(objError.Message, 'There was an error saving your data.');

                    $find('<%=RadNotification1.ClientID%>').set_text(errorString);
                    $find('<%=RadNotification1.ClientID%>').show();
                }
            });
        }

        function toggleLowerControls() {

            $('.cb-lowerextent').each(function (idx, itm) {
                var endoId = $(this).attr('data-endoscopistid');


                var ctrl = $find($(itm)[0].id);
                var successStatus = 'False';
                var selectedItem = ctrl.get_selectedItem();

                if (selectedItem != null) {
                    successStatus = selectedItem.get_attributes().getAttribute("data-successstatus");
                }

                if (successStatus == 'False' && ctrl.get_value() > 0) {
                    $(itm).closest('.lower-extent-options').find('tr.InsertionLimitedTr').show(); //Added by rony tfs-2830
                    $(itm).closest('.lower-extent-options').find('tr.InsertionConfirmedTr').show();
                    $(itm).closest('.lower-extent-options').find('tr.DifficultiesEncounteredTr').show(); //Added by rony tfs-2830
                    $(itm).closest('.lower-extent-options').find('tr.CaecumTimingTR').hide();
                    //reset controls
                    <%--$find('<%=CaecumTimeRadTimePicker.ClientID%>').get_dateInput().set_textBoxValue('');--%>

                    $(itm).closest('.lower-extent-options').find('tr.CaecumIdentifiedTr').hide();
                    //reset controls
                    var confirmedBy = $('.cb-insertionconfirmed[data-endoscopistid="' + endoId + '"]');
                    var confirmedByOther = $('.other-confirmed-by-entry[data-endoscopistid="' + endoId + '"]');

                    $find(confirmedBy[0].id).clearSelection();
                    $find(confirmedBy[0].id).set_value(0);

                    if ($find(confirmedByOther) != null)
                        $find(confirmedByOther[0].id).set_text(0);
                }
                else {
                    $(itm).closest('.lower-extent-options').find('tr.InsertionLimitedTr').hide();
                    //reset controls
                    //var limitationId = $('.cb-limitation[data-endoscopistid="' + endoId + '"]');
                    var limitationOther = $('.other-limitation-entry[data-endoscopistid="' + endoId + '"]');

                    //$find(limitationId[0].id).clearSelection();
                    //$find(limitationId[0].id).set_value(0);

                    if ($find(limitationOther) != null)
                        $find(limitationOther[0].id).set_text(0);


                    $(itm).closest('.lower-extent-options').find('tr.DifficultiesEncounteredTr').hide();
                    //reset controls
                    //var difficultyId = $('.cb-difficulties[data-endoscopistid="' + endoId + '"]');
                    var difficultyOther = $('.other-difficulty-entry[data-endoscopistid="' + endoId + '"]');

                    //$find(difficultyId[0].id).clearSelection();
                    //$find(difficultyId[0].id).set_value(0);

                    if ($find(difficultyOther) != null)
                        $find(difficultyOther[0].id).set_text(0);


                    $(itm).closest('.lower-extent-options').find('tr.InsertionConfirmedTr').show();
                    //reset controls


                    if (ctrl.get_text().toLowerCase() == 'caecum' || ctrl.get_text().toLowerCase() == 'terminal ileum') {
                        //$(itm).closest('.lower-extent-options').find('tr.CaecumTimingTR').show();
                        $(itm).closest('.lower-extent-options').find('tr.InsertionConfirmedTr').hide();
                        ////reset controls
                        var confirmedBy = $('.cb-insertionconfirmed[data-endoscopistid="' + endoId + '"]');
                        var confirmedByOther = $('.other-confirmed-by-entry[data-endoscopistid="' + endoId + '"]');

                        $find(confirmedBy[0].id).clearSelection();
                        $find(confirmedBy[0].id).set_value(0);

                        if ($find(confirmedByOther) != null)
                            $find(confirmedByOther[0].id).set_text(0);

                        $('.cb-caecumidentifiedby').each(function () {
                            var suppressed = $(this).attr('data-suppressed');
                            if (ctrl.get_text().toLowerCase() == 'caecum' && suppressed == 'True') {
                                $(this).closest('tr').hide();
                            } else {
                                $(this).closest('tr').show();
                            }
                        });

                        $(itm).closest('.lower-extent-options').find('tr.CaecumIdentifiedTr').show();
                    }
                    else {
                        $(itm).closest('.lower-extent-options').find('.CaecumTimingTR').hide();
                        //reset controls
                        <%--$find('<%=CaecumTimeRadTimePicker.ClientID%>').get_dateInput().set_textBoxValue('');--%>

                        $(itm).closest('.lower-extent-options').find('.CaecumIdentifiedTr').hide();
                        //reset controls  (is saved seperately so need to call function after to save it)

                        $(itm).closest('.lower-extent-options').find('.InsertionConfirmedTr').show();
                    }
                }

                if ($('.failed-lower-options input').is(':checked')) {
                    $(itm).closest('.lower-extent-options').find('tr.InsertionLimitedTr').show(); //Added by rony tfs-2830
                    $(itm).closest('.lower-extent-options').find('tr.DifficultiesEncounteredTr').show(); //Added by rony tfs-2830
                }
            });
        }

        function insertion_confirmed_by_changed(sender, args) {
            toggleLowerInsertionConfirmed();
            var endoscopistId = sender.get_attributes().getAttribute("data-endoscopistid");
            var selectedItem = sender.get_selectedItem();
            if (selectedItem) {
                confirmByOther = selectedItem.get_text().toLowerCase() === 'other';
            }
            saveLowerExtentData(endoscopistId);
        }
        function limitation_changed(sender, args) {
            toggleLowerLimitation();
            var endoscopistId = sender.get_attributes().getAttribute("data-endoscopistid");
            saveLowerExtentData(endoscopistId);
        }
        function difficulty_changed(sender, args) {
            toggleLowerDifficulty();
            var endoscopistId = sender.get_attributes().getAttribute("data-endoscopistid");
            saveLowerExtentData(endoscopistId);
        }


        function toggleLowerInsertionConfirmed() {
            $('.cb-insertionconfirmed').each(function (idx, itm) {
                var ctrl = $find($(itm)[0].id);
                if (ctrl.get_selectedItem() != null) {
                    var selectedText = ctrl.get_selectedItem().get_text().toLowerCase();

                    var otherInsertionConfirmedTR = $(itm).closest('.extent-results').find('.OtherInsertionConfirmed');

                    if (selectedText == 'other') {
                        $(otherInsertionConfirmedTR).show();
                    }
                    else {
                        $(otherInsertionConfirmedTR).hide();
                    }
                }
            });
        }

        function toggleLowerLimitation() {
            $('.cb-limitation').each(function (idx, itm) {
                var endoscopistId = $(this).attr('data-endoscopistid');
                var ctrl = $find($(itm)[0].id);
                if (ctrl.get_selectedItem() != null) {
                    var selectedText = ctrl.get_selectedItem().get_text().toLowerCase();

                    var otherLimitationTR = $(itm).closest('.extent-results').find('.OtherLimitation');

                    if (selectedText == 'other') {
                        $(otherLimitationTR).show();
                        limitationByOther = true;
                    }
                    else {
                        $(otherLimitationTR).hide();
                        limitationByOther = false;
                    }
                }
            });
        }
        function toggleNoRetroflexionReason() {
            $('.cb-retroflexion').each(function (idx, itm) {
                var endoscopistId = $(this).attr('data-endoscopistid');
                var retroflexion = $('.cb-retroflexion[data-endoscopistid="' + endoscopistId + '"]');
                var retroflexionDone = (retroflexion.length == 0) ? -1 : parseInt($find($(retroflexion)[0].id).get_value());

                if (retroflexionDone == 0) {
                    $(`#RetroflexionCancellationReason_${endoscopistId}`).show();
                }
                else {
                    $(`#RetroflexionCancellationReason_${endoscopistId}`).hide();
                }
            });
        }

        function toggleLowerDifficulty() {
            if (!$('.failed-lower-options input').is(':checked')) {
                $('.cb-difficulties').each(function (idx, itm) {
                    var ctrl = $find($(itm)[0].id);
                    if (ctrl.get_selectedItem() != null) {
                        var selectedText = ctrl.get_selectedItem().get_text().toLowerCase();

                        var otherDifficultiesTR = $(itm).closest('.extent-results').find('.otherDifficulties');
                        if (selectedText == 'other') {
                            $(otherDifficultiesTR).show();
                            difficultyOtherShow = true;
                        }
                        else {
                            $(otherDifficultiesTR).hide();
                            difficultyOtherShow = false;
                        }
                    }
                });
            }
        }

        function saveLowerExtent(sender, args) {
            var endoscopistId = sender.get_attributes().getAttribute("data-endoscopistid");
            saveLowerExtentData(endoscopistId);
        }

        function saveLowerExtentData(endoscopistId) {
         
            var rectalExamDone = $('.cb-prdone[data-endoscopistid="' + endoscopistId + '"]');
            var retroflexion = $('.cb-retroflexion[data-endoscopistid="' + endoscopistId + '"]');
            var noRetroflexionReason = $('.cb-retroflexion-reason[data-endoscopistid="' + endoscopistId + '"]');
            var insertionVia = $('.cb-insertionvia[data-endoscopistid="' + endoscopistId + '"]');
            var extentId = $('.cb-lowerextent[data-endoscopistid="' + endoscopistId + '"]');
            var confirmedBy = $('.cb-insertionconfirmed[data-endoscopistid="' + endoscopistId + '"]');
            var confirmedByOther = $('.other-confirmed-by-entry[data-endoscopistid="' + endoscopistId + '"]');
            var caecumIdentifiedById = $('.cb-caecumidentifiedby[data-endoscopistid="' + endoscopistId + '"]');
            var limitationId = $('.cb-limitation[data-endoscopistid="' + endoscopistId + '"]');
            var limitationOther = limitationByOther ? ($('.other-limitation-entry[data-endoscopistid="' + endoscopistId + '"]')) : '';
            var difficultyId = $('.cb-difficulties[data-endoscopistid="' + endoscopistId + '"]');
            var difficultyOther = difficultyOtherShow ? ($('.other-difficulty-entry[data-endoscopistid="' + endoscopistId + '"]')) : '';
            var abandoned = $('.failed-lower-options[data-failuretype="abandoned"] input');
            var intubationFailed = $('.failed-lower-options[data-failuretype="intubationfailed"] input');

            var obj = {};
            if ($('.failed-lower-options input').is(':checked')) {
                obj.abandoned = $(abandoned).is(':checked');
                obj.intubationFailed = $(intubationFailed).is(':checked');
            }
            else {
                obj.abandoned = false;
                obj.intubationFailed = false;
            }
            obj.procedureId = parseInt(<%= Session(UnisoftERS.Constants.SESSION_PROCEDURE_ID)%>);
            obj.rectalExam = (rectalExamDone.length == 0) ? -1 : parseInt($find($(rectalExamDone)[0].id).get_value());
            obj.retroflexion = (retroflexion.length == 0) ? -1 : parseInt($find($(retroflexion)[0].id).get_value());
            obj.noRetroflexionReason = ($(noRetroflexionReason).length == 0) ? '' : $(noRetroflexionReason).val();
            obj.insertionVia = (insertionVia.length == 0) ? 0 : parseInt($find($(insertionVia)[0].id).get_value());
            obj.confirmedById = (confirmedBy.length == 0) ? 0 : $find($(confirmedBy)[0].id).get_value();
            obj.confirmedByOther = confirmByOther ? (($(confirmedByOther).length == 0) ? '' : $(confirmedByOther).val()) : ''  //otherText;
            obj.caecumIdentifiedById = 0;
            //this needs removing from the DB!! then can remove from here
            obj.extentId = $find($(extentId)[0].id).get_value();
            obj.limitationId = (limitationId.length == 0) ? 0 : $find($(limitationId)[0].id).get_value();
            obj.limitationOther = ($(limitationOther).length == 0) ? '' : $(limitationOther).val(); //otherText;
            obj.difficultyId = (difficultyId.length == 0) ? 0 : $find($(difficultyId)[0].id).get_value();
            obj.difficultyOther = ($(difficultyOther).length == 0) ? '' : $(difficultyOther).val(); //otherText;
            obj.additionalInfo = '';
            obj.endoscopistId = endoscopistId;
            if (obj.retroflexion == 0) {
                $(`#RetroflexionCancellationReason_${endoscopistId}`).show();
            }
            else {
                $(`#RetroflexionCancellationReason_${endoscopistId}`).hide();
                obj.noRetroflexionReason = "";
                $(noRetroflexionReason).val("");
            }
            $.ajax({
                type: "POST",
                url: "../Procedure.aspx/saveLowerExtent",
                data: JSON.stringify(obj),
                dataType: "json",
                contentType: "application/json; charset=utf-8",
                success: function () {
                    if ($('.failed-lower-options input').is(':checked')) {
                        ////update timings and call their save method
                        //updateCaecumTimings(0);
                        //saveWithdrawalTime(0);
                    }
                    setRehideSummary();
                },
                error: function (x, y, z) {

                    autoSaveSuccess = false;
                    //show a message
                    var objError = x.responseJSON;
                    var errorString = buildErrorString(objError.Message, 'There was an error saving your data.');

                    $find('<%=RadNotification1.ClientID%>').set_text(errorString);
                    $find('<%=RadNotification1.ClientID%>').show();

                }
            });
        }

        function childDDL_changed(sender, args) {
            var selectedValue = args.get_item().get_value();
            var indicationId = sender.get_attributes().getAttribute('data-uniqueid');
            var endoId = sender.get_attributes().getAttribute('data-endoscopistid');

            saveData(indicationId, selectedValue, endoId, true);
        }

        // by Ferdowsi
        function handleCheckboxChange(checkbox) {
        var $checkbox = $(checkbox);
        var isChecked = $checkbox.prop('checked');
        var $parentTd = $checkbox.closest('td');
        var $childControl = $parentTd.find('.identifiedby-child');

        // Show/hide the child control based on the checkbox state
        if ($childControl.length > 0) {
            if (isChecked) {
                $childControl.show();
                $childControl.css('display', 'inline-block');
            } else {
                $childControl.hide();
            }
        }

        // Retrieve necessary attributes
        var uniqueId = $parentTd.find('.identifiedby-parent').attr('data-uniqueid');
        var endoId = $parentTd.find('.identifiedby-parent').attr('data-endoscopistid');
        // Auto-save
        saveData(uniqueId, 0, endoId, isChecked);
        }

        function resetLowerControls() {

            $('.cb-lowerextent').each(function (idx, itm) {
                var endoId = $(this).attr('data-endoscopistid');


                var ctrl = $find($(itm)[0].id);
                var successStatus = 'False';
                var selectedItem = ctrl.get_selectedItem();

                if (selectedItem != null) {
                    successStatus = selectedItem.get_attributes().getAttribute("data-successstatus");
                }

                if (successStatus == 'False' && ctrl.get_value() > 0) {
                    $(itm).closest('.lower-extent-options').find('tr.InsertionLimitedTr').show(); //Added by rony tfs-2830
                    $(itm).closest('.lower-extent-options').find('tr.InsertionConfirmedTr').show();
                    $(itm).closest('.lower-extent-options').find('tr.DifficultiesEncounteredTr').show(); //Added by rony tfs-2830
                    $(itm).closest('.lower-extent-options').find('tr.CaecumTimingTR').hide();
                    //reset controls
                    <%--$find('<%=CaecumTimeRadTimePicker.ClientID%>').get_dateInput().set_textBoxValue('');--%>

                    $(itm).closest('.lower-extent-options').find('tr.CaecumIdentifiedTr').hide();


                    $(itm).closest('.lower-extent-options').find('tr.CaecumIdentifiedTr .cb-caecumidentifiedby').each(function () {
                        $(this).find("input:checkbox:checked").prop('checked', false);
                        var id = $(this).closest('td').find('.identifiedby-parent').attr('data-uniqueid');
                        var endoId = $(this).closest('td').find('.identifiedby-parent').attr('data-endoscopistid');
                        var checked = $(this).is(':checked');
                        var childControl = $(this).closest('td').find('.identifiedby-child');
                        var comboBox = $find(childControl.attr('id'));
                        if (comboBox) {
                            comboBox.clearSelection();
                        }
                        saveData(id, 0, endoId, checked);
                        ceecumCheckBox = false;
                    });

                    //reset controls
                    var confirmedBy = $('.cb-insertionconfirmed[data-endoscopistid="' + endoId + '"]');
                    var confirmedByOther = $('.other-confirmed-by-entry[data-endoscopistid="' + endoId + '"]');

                    $find(confirmedBy[0].id).clearSelection();
                    $find(confirmedBy[0].id).set_value(0);

                    if ($find(confirmedByOther) != null)
                        $find(confirmedByOther[0].id).set_text(0);
                }
                else {
                    $(itm).closest('.lower-extent-options').find('tr.InsertionLimitedTr').hide();
                    //reset controls
                    var limitationId = $('.cb-limitation[data-endoscopistid="' + endoId + '"]');
                    var limitationOther = $('.other-limitation-entry[data-endoscopistid="' + endoId + '"]');

                    $find(limitationId[0].id).clearSelection();
                    $find(limitationId[0].id).set_value(0);

                    if ($find(limitationOther) != null)
                        $find(limitationOther[0].id).set_text(0);


                    $(itm).closest('.lower-extent-options').find('tr.DifficultiesEncounteredTr').hide();
                    //reset controls
                    var difficultyId = $('.cb-difficulties[data-endoscopistid="' + endoId + '"]');
                    var difficultyOther = $('.other-difficulty-entry[data-endoscopistid="' + endoId + '"]');

                    $find(difficultyId[0].id).clearSelection();
                    $find(difficultyId[0].id).set_value(0);

                    if ($find(difficultyOther) != null)
                        $find(difficultyOther[0].id).set_text(0);


                    $(itm).closest('.lower-extent-options').find('tr.InsertionConfirmedTr').show();
                    //reset controls


                    if (ctrl.get_text().toLowerCase() == 'caecum' || ctrl.get_text().toLowerCase() == 'terminal ileum') {
                        $(itm).closest('.lower-extent-options').find('tr.CaecumTimingTR').show();
                        $(itm).closest('.lower-extent-options').find('tr.InsertionConfirmedTr').hide();
                        ////reset controls
                        var confirmedBy = $('.cb-insertionconfirmed[data-endoscopistid="' + endoId + '"]');
                        var confirmedByOther = $('.other-confirmed-by-entry[data-endoscopistid="' + endoId + '"]');

                        $find(confirmedBy[0].id).clearSelection();
                        $find(confirmedBy[0].id).set_value(0);

                        if ($find(confirmedByOther) != null)
                            $find(confirmedByOther[0].id).set_text(0);


                        $(itm).closest('.lower-extent-options').find('tr.CaecumIdentifiedTr').show();
                    }
                    else {
                        $(itm).closest('.lower-extent-options').find('.CaecumTimingTR').hide();
                    //reset controls
                        <%--$find('<%=CaecumTimeRadTimePicker.ClientID%>').get_dateInput().set_textBoxValue('');--%>

                        $(itm).closest('.lower-extent-options').find('.CaecumIdentifiedTr').hide();


                        $(itm).closest('.lower-extent-options').find('tr.CaecumIdentifiedTr .cb-caecumidentifiedby').each(function () {
                            $(this).find("input:checkbox:checked").prop('checked', false);
                            var id = $(this).closest('td').find('.identifiedby-parent').attr('data-uniqueid');
                            var endoId = $(this).closest('td').find('.identifiedby-parent').attr('data-endoscopistid');
                            var checked = $(this).is(':checked');
                            var childControl = $(this).closest('td').find('.identifiedby-child');
                            var comboBox = $find(childControl.attr('id'));
                            if (comboBox) {
                                comboBox.clearSelection();
                            }
                            saveData(id, 0, endoId, checked);
                            ceecumCheckBox = false;
                        });

                        //reset controls  (is saved seperately so need to call function after to save it)

                        $(itm).closest('.lower-extent-options').find('.InsertionConfirmedTr').show();
                    }
                }

                if ($('.failed-lower-options input').is(':checked')) {
                    $(itm).closest('.lower-extent-options').find('tr.InsertionLimitedTr').show(); //Added by rony tfs-2830
                    $(itm).closest('.lower-extent-options').find('tr.DifficultiesEncounteredTr').show(); //Added by rony tfs-2830
                }
            });
        }
    </script>
</telerik:RadScriptBlock>
<telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" Title="<div class='aspxValidationSummaryHeader'>Please correct the following</div>"
    Skin="Metro" Position="Center" BorderColor="Red" AutoCloseDelay="0" Width="400" ContentIcon="warning" ShowCloseButton="true" EnableShadow="true" EnableRoundedCorners="true" />
<%--<asp:UpdatePanel ID="UpdatePanel1" runat="server" UpdateMode="Always">

    <ContentTemplate>--%>

        <div class="control-content" id="LowerExtentContent" runat="server">
            <asp:Repeater ID="rptFailedOutcomes" runat="server" OnItemDataBound="rptFailedOutcomes_ItemDataBound">
                <HeaderTemplate>
                    <table>
                </HeaderTemplate>
                <ItemTemplate>
                    <tr>
                        <td>
                            <%#Eval("Description") %>
                        </td>
                        <td>
                            <asp:HiddenField ID="ExtentHiddenField" runat="server" Value='<%#Eval("UniqueId") %>' />
                            <asp:CheckBox ID="cbFailedOption" runat="server" data-extentid='<%#Eval("UniqueId") %>' data-failuretype='<%#Eval("Description").ToString.ToLower.Replace(" ", "") %>' CssClass="failed-lower-options" />
                        </td>
                    </tr>
                </ItemTemplate>
                <FooterTemplate>
                    </table>
                </FooterTemplate>
            </asp:Repeater>

            <asp:Repeater ID="rptLowerExtent" runat="server" OnItemDataBound="rptLowerExtent_ItemDataBound">
                <HeaderTemplate>
                    <table style="width: 100%;" class="endo-extent">
                        <tr>
                </HeaderTemplate>
                <ItemTemplate>
                    <td style="width: 50%;">
                        <asp:HiddenField ID="EndoscopistIdHiddenValue" runat="server" Value='<%#Eval("EndoscopistId") %>' />
                        <asp:Label ID="lblEndoscopistName" runat="server" Text='<%#Eval("EndoscopistName") %>' Style="font-weight: bold; font-size: 14px;" />
                         <%--Added by rony tfs-3761--%>
                        <asp:Label ID="Label3" runat="server" Text='<%#Eval("TraineeTrainer") %>' Style="font-size: 13px;" /> 
                        <table>
                            <tr>
                                <td>Retroflexion done?</td>
                                <td>
                                    <telerik:RadComboBox ID="RetroflexionDoneRadComboBox" runat="server" Skin="Metro" CssClass="cb-retroflexion" OnClientSelectedIndexChanged="saveLowerExtent">
                                        <Items>
                                            <telerik:RadComboBoxItem Text="Yes" Value="1" />
                                            <telerik:RadComboBoxItem Text="No" Value="0" />
                                        </Items>
                                    </telerik:RadComboBox>
                                </td>

                            </tr>
                            <tr id="RetroflexionCancellationReason_<%#Eval("EndoscopistId") %>">
                                <td>Reason</td>
                                <td style="vertical-align: bottom;">
                                    <asp:TextBox ID="NoRetroflexionReasonTextBox" runat="server" Skin="Metro" Width="160" CssClass="cb-retroflexion-reason" />
                                </td>
                            </tr>
                            <tr>
                                <td>Rectal exam (PR) done?</td>
                                <td>
                                    <telerik:RadComboBox ID="PRDoneRadComboBox" runat="server" Skin="Metro" CssClass="cb-prdone" OnClientSelectedIndexChanged="saveLowerExtent">
                                        <Items>
                                            <telerik:RadComboBoxItem Text="Yes" Value="1" />
                                            <telerik:RadComboBoxItem Text="No" Value="0" />
                                        </Items>
                                    </telerik:RadComboBox>
                                </td>
                            </tr>
                        </table>
                        <table class="lower-extent-options extent-results">
                            <tr>
                                <td colspan="2"></td>
                            </tr>
                            <tr>
                                <td>Insertion via:</td>
                                <td>
                                    <telerik:RadComboBox ID="InsertionViaRadComboBox" runat="server" Skin="Metro" DataTextField="Description" DataValueField="UniqueId" OnClientSelectedIndexChanged="saveLowerExtent" CssClass="cb-insertionvia" />
                                </td>
                            </tr>
                            <tr class="resetLowerExtent plannedLabel">
                                <td>Insertion to:</td>
                                <td>
                                    <telerik:RadComboBox ID="LowerExtentComboBox" runat="server" CssClass="extent-control cb-lowerextent" Skin="Metro" DataTextField="Description" DataValueField="UniqueId" OnClientSelectedIndexChanged="lower_extent_changed" OnItemDataBound="LowerExtentComboBox_ItemDataBound"/>
                                </td>
                            </tr>
                            <tr class="InsertionConfirmedTr" id="InsertionConfirmedTr" runat="server">
                                <td>Insertion confirmed by:</td>
                                <td>
                                    <telerik:RadComboBox ID="InsertionComfirmedRadComboBox" runat="server" CssClass="extent-control cb-insertionconfirmed" Skin="Metro" DataTextField="Description" DataValueField="UniqueId" OnClientSelectedIndexChanged="insertion_confirmed_by_changed" />
                                </td>
                            </tr>
                            <tr runat="server" class="InsertionConfirmedTr">
                                <td><span class="other-reason-label OtherInsertionConfirmed">other confirmation</span>&nbsp;</td>
                                <td>
                                    <asp:TextBox ID="OtherConfirmedByTextBox" runat="server" Skin="Metro" CssClass="other-confirmed-by-entry OtherInsertionConfirmed" />&nbsp;
                                </td>
                            </tr>
                            <tr class="CaecumIdentifiedTr" id="CaecumIdentifiedTr" runat="server">
                                <td>Caecum identified by:</td>
                                <td>
                                    <asp:Repeater ID="CaecumIdentifiedByRepeater" runat="server">
                                        <HeaderTemplate>
                                            <table cellpadding="0" cellspacing="0" style="width: 100%;">
                                                <tr>
                                        </HeaderTemplate>
                                        <ItemTemplate>
                                            <%# IIf(Container.ItemIndex Mod 1 = 0, "</tr><tr>", "")%>
                                            <td>
                                                <asp:HiddenField ID="CaecumIdentifierHiddenField" runat="server" Value='<%# Eval("UniqueId") %>' />
                                                <asp:CheckBox ID="DataboundCheckbox" runat="server" Text='<%# Eval("Description") %>' data-uniqueid='<%# Eval("UniqueId") %>' CssClass="identifiedby-parent cb-caecumidentifiedby" />
                                            </td>
                                        </ItemTemplate>
                                        <FooterTemplate>
                                            </tr>
                                        </table>
                                        </FooterTemplate>
                                    </asp:Repeater>
                                </td>
                            </tr>
                            <tr class="InsertionLimitedTr" id="InsertionLimitedTrID" runat="server">
                                <td><b>
                                    <asp:Label runat="server" ID="InsertionlimitedLabel" Text="Insertion limited by" /><img src="../../Images/NEDJAG/JAGNED.png" />
                                </b></td>
                                <td>
                                    <telerik:RadComboBox ID="InsertionLimitedRadComboBox" runat="server" CssClass="extent-control cb-limitation" Skin="Metro" DataTextField="Description" DataValueField="UniqueId" OnClientSelectedIndexChanged="limitation_changed" />
                                </td>
                            </tr>
                            <tr runat="server" class="InsertionLimitedTr">
                                <td><span class="other-reason-label OtherLimitation">other limitation</span>&nbsp;</td>
                                <td>
                                    <asp:TextBox ID="OtherLimitationTextBox" runat="server" Skin="Metro" CssClass="other-limitation-entry OtherLimitation" />&nbsp;
                                </td>
                            </tr>
                            <tr class="DifficultiesEncounteredTr" id="DifficultiesEncounteredTr" runat="server">
                                <td><b>
                                    <asp:Label runat="server" ID="DifficultiesLabel" Text="Difficulties encountered" /><img src="../../Images/NEDJAG/JAG.png" />
                                </b></td>
                                <td>
                                    <telerik:RadComboBox ID="DifficultiesEncounteredRadComboBox" runat="server" CssClass="extent-control cb-difficulties" Skin="Metro" DataTextField="Description" DataValueField="UniqueId" OnClientSelectedIndexChanged="difficulty_changed"/>
                                </td>
                            </tr>
                            <tr runat="server" id="DifficultiesEncounteredOtherTrID">
                                <td><span class="other-difficulty-label otherDifficulties">other difficulty</span>&nbsp;</td>
                                <td>
                                    <asp:TextBox ID="OtherDifficultyTextBox" runat="server" Skin="Metro" CssClass="other-difficulty-entry otherDifficulties" />&nbsp;
                                </td>
                            </tr>
                        </table>
                    </td>
                </ItemTemplate>
                <FooterTemplate>
                    </tr>
            </table>
                </FooterTemplate>
            </asp:Repeater>
        </div>

    <%--</ContentTemplate>

</asp:UpdatePanel>--%>

<telerik:RadWindowManager ID="WindowManager1" runat="server" ShowContentDuringLoad="false" Style="z-index: 7001" Behaviors="Close, Move" Skin="Metro" EnableShadow="True" Modal="True" Behavior="Close, Move">
    <Windows>
        <telerik:RadWindow ID="ImagePickerRadWindow" runat="server" ReloadOnShow="true" KeepInScreenBounds="true" Width="340px" Height="150px" Skin="Metro" Title="Choose image" VisibleStatusbar="false" Animation="None">
            <ContentTemplate></ContentTemplate>
        </telerik:RadWindow>
    </Windows>
</telerik:RadWindowManager>
