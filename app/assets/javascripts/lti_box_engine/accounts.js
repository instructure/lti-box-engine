App = Ember.Application.create({
  rootElement: '#ember-app'
});

App.Router.map(function() {
});

App.ApplicationAdapter = DS.ActiveModelAdapter.extend({
  host: Em.ENV.HOST
});

App.Account = DS.Model.extend({
  name:        DS.attr(),
  oauthKey:    DS.attr(),
  oauthSecret: DS.attr()
});

App.IndexRoute = Ember.Route.extend({
  model: function() {
    return this.store.find('account');
  }
});

App.IndexController = Ember.ArrayController.extend({
  actions: {
    addAccount: function() {
      var _this = this,
          props = this.getProperties('newName', 'newOauthKey', 'newOauthSecret'),
          account = this.store.createRecord('account', {
            name: props.newName,
            oauthKey: props.newOauthKey,
            oauthSecret: props.newOauthSecret
          });
      
      account.save().then(function(data) {
        _this.set('newName', '');
        _this.set('newOauthKey', '');
        _this.set('newOauthSecret', '');
        Ember.debug("Saved account!")
      }).catch(function(err) {
        _this.removeObject(account);
        alert(err.responseText);
      });
    },

    editAccount: function(account) {
      account.set('isEditing', true);
    },

    saveAccount: function(account) {
      account.save().then(function(data) {
        Ember.run(this, function() {
          this.findBy('id', data.id).set('isEditing', false);
          Ember.debug("Saved account!")
        });
      }.bind(this)).catch(function(err) {
        alert(err.errors[0]);
      });
    },

    deleteAccount: function(account) {
      if (confirm("Are you sure?")) {
        account.destroyRecord();
      }
    }
  }
})