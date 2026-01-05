export type ChoiceNotificationInfo = {
    InfoText: string,
    Button1Text: string,
    Button2Text: string,
    Button1Cb: () -> ()?,
    Button2Cb: () -> ()?,   
}

export type GenericNotificationInfo = {
    InfoText: string,
    Button1Text: string,
    Cb: () -> ()?,
}

return nil