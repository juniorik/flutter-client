import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:redux/redux.dart';
import 'package:invoiceninja_flutter/redux/app/app_actions.dart';
import 'package:invoiceninja_flutter/utils/platforms.dart';
import 'package:invoiceninja_flutter/data/models/models.dart';
import 'package:invoiceninja_flutter/redux/ui/ui_actions.dart';
import 'package:invoiceninja_flutter/ui/recurring_invoice/recurring_invoice_screen.dart';
import 'package:invoiceninja_flutter/ui/recurring_invoice/edit/recurring_invoice_edit_vm.dart';
import 'package:invoiceninja_flutter/ui/recurring_invoice/view/recurring_invoice_view_vm.dart';
import 'package:invoiceninja_flutter/redux/recurring_invoice/recurring_invoice_actions.dart';
import 'package:invoiceninja_flutter/redux/app/app_state.dart';
import 'package:invoiceninja_flutter/data/repositories/recurring_invoice_repository.dart';

List<Middleware<AppState>> createStoreRecurringInvoicesMiddleware([
  RecurringInvoiceRepository repository = const RecurringInvoiceRepository(),
]) {
  final viewRecurringInvoiceList = _viewRecurringInvoiceList();
  final viewRecurringInvoice = _viewRecurringInvoice();
  final editRecurringInvoice = _editRecurringInvoice();
  final loadRecurringInvoices = _loadRecurringInvoices(repository);
  final loadRecurringInvoice = _loadRecurringInvoice(repository);
  final saveRecurringInvoice = _saveRecurringInvoice(repository);
  final archiveRecurringInvoice = _archiveRecurringInvoice(repository);
  final deleteRecurringInvoice = _deleteRecurringInvoice(repository);
  final restoreRecurringInvoice = _restoreRecurringInvoice(repository);

  return [
    TypedMiddleware<AppState, ViewRecurringInvoiceList>(
        viewRecurringInvoiceList),
    TypedMiddleware<AppState, ViewRecurringInvoice>(viewRecurringInvoice),
    TypedMiddleware<AppState, EditRecurringInvoice>(editRecurringInvoice),
    TypedMiddleware<AppState, LoadRecurringInvoices>(loadRecurringInvoices),
    TypedMiddleware<AppState, LoadRecurringInvoice>(loadRecurringInvoice),
    TypedMiddleware<AppState, SaveRecurringInvoiceRequest>(
        saveRecurringInvoice),
    TypedMiddleware<AppState, ArchiveRecurringInvoicesRequest>(
        archiveRecurringInvoice),
    TypedMiddleware<AppState, DeleteRecurringInvoicesRequest>(
        deleteRecurringInvoice),
    TypedMiddleware<AppState, RestoreRecurringInvoicesRequest>(
        restoreRecurringInvoice),
  ];
}

Middleware<AppState> _editRecurringInvoice() {
  return (Store<AppState> store, dynamic dynamicAction, NextDispatcher next) {
    final action = dynamicAction as EditRecurringInvoice;

    next(action);

    store.dispatch(UpdateCurrentRoute(RecurringInvoiceEditScreen.route));

    if (isMobile(action.context)) {
      action.navigator.pushNamed(RecurringInvoiceEditScreen.route);
    }
  };
}

Middleware<AppState> _viewRecurringInvoice() {
  return (Store<AppState> store, dynamic dynamicAction,
      NextDispatcher next) async {
    final action = dynamicAction as ViewRecurringInvoice;

    next(action);

    store.dispatch(UpdateCurrentRoute(RecurringInvoiceViewScreen.route));

    if (isMobile(action.context)) {
      Navigator.of(action.context).pushNamed(RecurringInvoiceViewScreen.route);
    }
  };
}

Middleware<AppState> _viewRecurringInvoiceList() {
  return (Store<AppState> store, dynamic dynamicAction, NextDispatcher next) {
    final action = dynamicAction as ViewRecurringInvoiceList;

    next(action);

    if (store.state.staticState.isStale) {
      store.dispatch(RefreshData());
    }

    store.dispatch(UpdateCurrentRoute(RecurringInvoiceScreen.route));

    if (isMobile(action.context)) {
      Navigator.of(action.context).pushNamedAndRemoveUntil(
          RecurringInvoiceScreen.route, (Route<dynamic> route) => false);
    }
  };
}

Middleware<AppState> _archiveRecurringInvoice(
    RecurringInvoiceRepository repository) {
  return (Store<AppState> store, dynamic dynamicAction, NextDispatcher next) {
    final action = dynamicAction as ArchiveRecurringInvoicesRequest;
    final prevRecurringInvoices = action.recurringInvoiceIds
        .map((id) => store.state.recurringInvoiceState.map[id])
        .toList();
    repository
        .bulkAction(store.state.credentials, action.recurringInvoiceIds,
            EntityAction.archive)
        .then((List<InvoiceEntity> recurringInvoices) {
      store.dispatch(ArchiveRecurringInvoicesSuccess(recurringInvoices));
      if (action.completer != null) {
        action.completer.complete(null);
      }
    }).catchError((Object error) {
      print(error);
      store.dispatch(ArchiveRecurringInvoicesFailure(prevRecurringInvoices));
      if (action.completer != null) {
        action.completer.completeError(error);
      }
    });

    next(action);
  };
}

Middleware<AppState> _deleteRecurringInvoice(
    RecurringInvoiceRepository repository) {
  return (Store<AppState> store, dynamic dynamicAction, NextDispatcher next) {
    final action = dynamicAction as DeleteRecurringInvoicesRequest;
    final prevRecurringInvoices = action.recurringInvoiceIds
        .map((id) => store.state.recurringInvoiceState.map[id])
        .toList();
    repository
        .bulkAction(store.state.credentials, action.recurringInvoiceIds,
            EntityAction.delete)
        .then((List<InvoiceEntity> recurringInvoices) {
      store.dispatch(DeleteRecurringInvoicesSuccess(recurringInvoices));
      if (action.completer != null) {
        action.completer.complete(null);
      }
    }).catchError((Object error) {
      print(error);
      store.dispatch(DeleteRecurringInvoicesFailure(prevRecurringInvoices));
      if (action.completer != null) {
        action.completer.completeError(error);
      }
    });

    next(action);
  };
}

Middleware<AppState> _restoreRecurringInvoice(
    RecurringInvoiceRepository repository) {
  return (Store<AppState> store, dynamic dynamicAction, NextDispatcher next) {
    final action = dynamicAction as RestoreRecurringInvoicesRequest;
    final prevRecurringInvoices = action.recurringInvoiceIds
        .map((id) => store.state.recurringInvoiceState.map[id])
        .toList();
    repository
        .bulkAction(store.state.credentials, action.recurringInvoiceIds,
            EntityAction.restore)
        .then((List<InvoiceEntity> recurringInvoices) {
      store.dispatch(RestoreRecurringInvoicesSuccess(recurringInvoices));
      if (action.completer != null) {
        action.completer.complete(null);
      }
    }).catchError((Object error) {
      print(error);
      store.dispatch(RestoreRecurringInvoicesFailure(prevRecurringInvoices));
      if (action.completer != null) {
        action.completer.completeError(error);
      }
    });

    next(action);
  };
}

Middleware<AppState> _saveRecurringInvoice(
    RecurringInvoiceRepository repository) {
  return (Store<AppState> store, dynamic dynamicAction, NextDispatcher next) {
    final action = dynamicAction as SaveRecurringInvoiceRequest;
    repository
        .saveData(store.state.credentials, action.recurringInvoice)
        .then((InvoiceEntity recurringInvoice) {
      if (action.recurringInvoice.isNew) {
        store.dispatch(AddRecurringInvoiceSuccess(recurringInvoice));
      } else {
        store.dispatch(SaveRecurringInvoiceSuccess(recurringInvoice));
      }

      action.completer.complete(recurringInvoice);
    }).catchError((Object error) {
      print(error);
      store.dispatch(SaveRecurringInvoiceFailure(error));
      action.completer.completeError(error);
    });

    next(action);
  };
}

Middleware<AppState> _loadRecurringInvoice(
    RecurringInvoiceRepository repository) {
  return (Store<AppState> store, dynamic dynamicAction, NextDispatcher next) {
    final action = dynamicAction as LoadRecurringInvoice;
    final AppState state = store.state;

    store.dispatch(LoadRecurringInvoiceRequest());
    repository
        .loadItem(state.credentials, action.recurringInvoiceId)
        .then((recurringInvoice) {
      store.dispatch(LoadRecurringInvoiceSuccess(recurringInvoice));

      if (action.completer != null) {
        action.completer.complete(null);
      }
    }).catchError((Object error) {
      print(error);
      store.dispatch(LoadRecurringInvoiceFailure(error));
      if (action.completer != null) {
        action.completer.completeError(error);
      }
    });

    next(action);
  };
}

Middleware<AppState> _loadRecurringInvoices(
    RecurringInvoiceRepository repository) {
  return (Store<AppState> store, dynamic dynamicAction, NextDispatcher next) {
    final action = dynamicAction as LoadRecurringInvoices;
    final AppState state = store.state;

    store.dispatch(LoadRecurringInvoicesRequest());
    repository.loadList(state.credentials).then((data) {
      store.dispatch(LoadRecurringInvoicesSuccess(data));

      if (action.completer != null) {
        action.completer.complete(null);
      }
      /*
      if (state.productState.isStale) {
        store.dispatch(LoadProducts());
      }
      */
    }).catchError((Object error) {
      print(error);
      store.dispatch(LoadRecurringInvoicesFailure(error));
      if (action.completer != null) {
        action.completer.completeError(error);
      }
    });

    next(action);
  };
}
