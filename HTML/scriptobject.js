function uuidgen() {
	return('xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
		var r = Math.random()*16|0, v = c == 'x' ? r : (r&0x3|0x8);
		return v.toString(16);
	}).toUpperCase());
};

var FakeConsole = new Class({
	initialize: function(){
	},
	log: function(obj) {
		window.scriptObject.call('_console_log', obj, null);
	},
});

var ScriptObject = new Class({
	initialize: function(){
		this.callbacks = [];
	},

	call: function(id, args, callback) {

		var payload = { id: id, args: args };
		if (callback)
			{
			var callback_uuid = uuidgen();
			this.callbacks[callback_uuid] = callback;
			payload.callback_uuid = callback_uuid
			}
		var s = JSON.stringify(payload)
		s = encodeURIComponent(s)

		var url = 'x-script-call:' + s
		window.location = url;
	},

	callback: function(callback_uuid, args) {
		try
			{
			var callback = this.callbacks[callback_uuid];
			if (callback)
				{
				theResult = callback(args);
				delete this.callbacks[callback_uuid];
				var d = { result: theResult, success: true }
				var s = JSON.stringify(d);
				return(s);
				}
			var d = { error: 'callback_uuid not found', success: false }
			var s = JSON.stringify(d);
			return(s);
			}
		catch (err)
			{
			console.log(err);
			var d = { error: err, success: false }
			var s = JSON.stringify(d);
			return(s);
			}
	},

});

