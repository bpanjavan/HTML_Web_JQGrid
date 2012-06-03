/* Holds UI settings as JSON Objects */

var UISettings =  
{
    TestSetting: "Test Setting Value"        
    ,
    JQueryUI : 
    {
        ModalDialogOption :
                            {
                                autoOpen: false
                                , show:
                                    {
                                        effect: "fade"
                                    }
                                , hide:
                                    {
                                        effect: "fade"
                                        , direction: "down" // doesn't work for "fade", try "drop"
                                    }
                                , modal: true
                            }
    }
}






