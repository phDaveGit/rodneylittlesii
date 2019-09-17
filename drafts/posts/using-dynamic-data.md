Title: Get started using Dynamic Data
Drafted: 09/16/2019
Published: 09/16/2019
Tags:
    - DynamicData
    - ReactiveUI
    - Xamarin Forms
---

# So this DD thing

# I use Rx; dd broke my brain

# Where does the data come from?

# ReadOnlyObservableCollection?!
Turns out, `ReadOnly` in this case, doesn't mean you can't write to it.  It means it doesn't have public access via `{ get; set; }` and instead you have to use public access functions like `Add()` in order to get new items into the collection.