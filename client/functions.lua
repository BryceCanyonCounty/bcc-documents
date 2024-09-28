--Pulling Essentials
VORPcore = exports.vorp_core:GetCore()
BccUtils = exports['bcc-utils'].initiate()
FeatherMenu =  exports['feather-menu'].initiate()

BCCDocumentsMainMenu = FeatherMenu:RegisterMenu('bcc-documents:mainmenu', {
    top = '5%',
    left = '5%',
    ['720width'] = '500px',
    ['1080width'] = '600px',
    ['2kwidth'] = '700px',
    ['4kwidth'] = '900px',
    style = {},
    contentslot = {
      style = {
        ['height'] = '350px',
        ['min-height'] = '250px'
      }
    },
    draggable = true
  }, {
    opened = function()
        DisplayRadar(false)
    end,
    closed = function()
        DisplayRadar(true)
    end,
})