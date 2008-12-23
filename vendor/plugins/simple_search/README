ActiveSearch is a barbarian way to give your models a sparkle of fuzzy search, which most users will surely prefer
to very specific forms.

You can find ActiveSearch in it's SVN repository at

  http://julik.textdriven.com/svn/tools/rails_plugins/simple_search
  
And yes the repository is called like that for historical reasons.

== Basic examples

  class Photo
    indexes_columns
  end

will index all attributes into the field called "searchable" (with ActiveSearch::LikeIndexer)

  class Page < ActiveRecord::Base
    indexes_columns :title, :body
  end

will index only title and body attributes into the field called "searchable" (with ActiveSearch::LikeIndexer)

  class BlogEntry < ActiveRecord::Base
    indexes_columns :except=>'date', :into=>'index', :including_associations=>false
  end
  
will index all attributes of the entry (except the date and associated objects) into field called "index"

You can also specify a condition for the index update. To index only approved articles, for instance, you can pass a symbol
of the boolean attribute of the model:

  class Article < ActiveRecord::Base
    indexes_columns :title, :body, :tags, :if => :approved?
  end
  
A condition should be a method reference or a Proc.

  class Article < ActiveRecord::Base
    indexes_columns :title, :body, :if => Proc.new{|a| a.status != 'draft' }
  end


By default only "content" attributes (dates, times, strings and integers) and foreign keys are indexed,
but only one level downstream. This makes sense if you want to include Tags into your searchable string for an actual
model (like a Photo). An "index representation" (string of tokens) is retrieved from the associated objects.

This representation is automatically aliased to Object#to_s method, but you can define index_repr to override
this behaviour. 

Dates and times also provide an index representation automatically, in the form of
current day, year, month name and time - so you can searh for +january+. You can optionally add methods that return optimum
index representations of a particulaer attribute (literally "put an attribute into words"), in the form of:

  class BlogEntry < ActiveRecord::Base
    ...
    def index_repr_of_comments
      "commented"
    end
    
    def index_repr_of_tracbacks
      'pinged'
    end
  end

After you defined the column and reindexed the models you can do simple searches on your models.
If you supply many terms they are going to be searched for with AND keyword

  entries = BlogEntry.find_using_term("Rails")
  entries = BlogEntry.find_using_term("Rails Foo Bar Baz")

This can instantly be hooked into an API or a controller that searches across models.

== Using different indexers

However, this is not the only way to use ActiveSearch. Under the hood ActiveSearch uses a number of Indexers to perform
searches. Every time you call the macro "indexes_columns" an ActiveSearch::Indexer is created on your model. You can get to these indexers via the Model.indexers method

  Entry.indexers # => [<ActiveSearch::LikeIndexer>]
  
When you call find_using_term all of the indexers will be asked to search their indexes. If you want to be more specific and
ask a special Indexer, you do it by addressing the indexers array directly and using the +query+ method:

  Entry.indexers[0].query("Foo")
  
Currently ActiveSearch has three indexers. You can define as many indexers as you want per
model, however if their options and class are the same they will be concatenated (i.e. no 2 duplicate indexers will be defined).

To switch indexers you use the :using key of the +indexes_columns+ method. In this option you can supply your own class (it
should be a descendant of ActiveSearch::Indexer):

 class Entry < ActiveRecord::Base
  indexes_columns :foo, :bar, :using=>MyCoolIndexer
 end
 
or a symbol which will be expanded with "indexer"

  indexes_columns :foo, :bar, :using => :term # Will create a TermIndexer

Note that when performing queries the indexers will (by default) use the scoping defined for the model itself (because under the hood
they use the +find+ method of ActiveRecord)! It means that you can get relatively fast searching when your query
is scoped tightly enough outside of the fuzzy search using ActiveRecord

  Page.with_scope(:find => { :conditions => "site_id = 1" }) do
     Quote.find_with_term("bla", "baz") # SELECT * FROM quotes WHERE page_id = ... AND idx LIKE "%bla%" AND idx LIKE "%baz%"
  end
  
To rebuild the indexes you ask the indexers to do it:

  Entry.indexers[0].rebuild! # will take time

or rebuild all the indexes at once
  
  Entry.simply_reindex! # will take quite some time
  


== Searching using LIKE (and indexing with ActiveSearch::LikeIndexer)

This is the simplest and default one. Use it when you have little tables (up to 500 records) or the queries will be highly scoped.

It works by pulling the index representation into a separate column of the model table itself and then issuing
an inclusive LIKE query on them. Of course in this case you get no search rankings.

The :into option specifies the column that will hold the index text.

  class Entry < ActiveRecord::Base
    indexes_columns :title, :body, :date, :using=>:like, :into=>'column_for_indexes'
  end

== Searching using a "terms" table (and indexing with ActiveSearch::TermIndexer)

The TermIndexer will use a table called search_terms and a model SearchTerm with the attribute "term". When your records
are saved, the terms will automatically be scavenged from your models and joins will be created in the join table.

It will be much more effective if you have more text and/or bigger tables. You will also be able
to perform simple stats (in how many of your models a certain term is used) using the tables created. The default table
for search terms is called 'search_terms' and the default model is SearchTerm

The :into option specifies the table used for storing your search terms.

  class Entry < ActiveRecord::Base
    indexes_columns :title, :body, :using=>:term
  end
  
If you don't have a SearchTerm model yet it is going to be automatically created for you with all the associations in place, as
  
  class SearchTerm < ActiveRecord::Base
     has_and_belongs_to_many :entries
     validates_uniqueness_of :term
  end
  
Please note that it will bail if you don't have all the tables defined. Currently it also won't delete the actual search terms
after a model is being deleted - only the associations are going to be removed from the join table. This has to do with the
fact that the terms might also be used in other associations, as well as for indexing other model classes. For example, you can
index two different models using the same term model (provided you have +entries_search_terms+ and +authors_search_terms+ defined):

  class Entry < ActiveRecord::Base
    indexes_columns :using=>:term
  end

  class Author < ActiveRecord::Base
    indexes_columns :using=>:term
  end

==Indexing into Ferret

Ferret by Dave Balmain is a highly configurable, powerful port of Lucene to Ruby and C.
It stores it's indexes in it's own format, so integrating it with ActiveRecord is not very
easy - however this Indexer should give you a reasonable start. Take care to configure the underlying
Ferret::Index::Index object yourself to achieve optimum search results.

Primarily because Ferret is so flexible, this indexer also accepts a "by" option, which will accept a proc and
allow you to customize the index refresh. The Ferret index and the record are going to be
passed to the proc.

This indexer does not use the ActiveRecord::Base#index_repr method, but instead
will delegate tokenization and typecasting to Ferret. This, by default, will give you very good string representations
of objects such as Date, Time etc.

However, if you define "index_repr_of_attribute" for one or more attributes the indexer is going to use them.

	class Entry < ActiveRecord::Base
	  indexes_columns :using=>:ferret, :into=>RAILS_ROOT + '/entries.index', :separate_columns => true, 
			:ferret_options => {:auto_flush => true}
	end

== Licensing

This software is distributed under MIT license and is expected to be sloppy.

== Feedback

Please send all your failing unit tests, questions, complaints and feature requests to me at julik dot nl.

Made by http://julik.nl