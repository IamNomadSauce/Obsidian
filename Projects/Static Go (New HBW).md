TODO:
- [ ] Go Curriculum
	- [ ] Project Directory structure
	- [ ] Server structure (multiple services)
https://pkg.go.dev/text/template
https://blog.questionable.services/article/approximating-html-template-inheritance/
https://philipptanlak.com/mastering-html-templates-in-go-the-fundamentals/

```
mux.Handle("/route1", middleware(logger, db, slackClient, rroll []byte, handleSomething(handlerSpecificDeps))
mux.Handle("/route2", middleware(logger, db, slackClient, rroll []byte, handleSomething2(handlerSpecificDeps))
mux.Handle("/route3", middleware(logger, db, slackClient, rroll []byte, handleSomething3(handlerSpecificDeps))
mux.Handle("/route4", middleware(logger, db, slackClient, rroll []byte, handleSomething4(handlerSpecificDeps))

This bloats out the code and doesn’t really provide anything useful. Instead, I would have the middleware function take the dependencies, but return a function that takes only the next handler.
Go

func newMiddleware(
	logger Logger,
	db *DB,
	slackClient *slack.Client,
	rroll []byte,
) func(h http.Handler) http.Handler

The return type func(h http.Handler) http.Handler is the function that we will call when setting up our routes.
Go

middleware := newMiddleware(logger, db, slackClient, rroll)
mux.Handle("/route1", middleware(handleSomething(handlerSpecificDeps))
mux.Handle("/route2", middleware(handleSomething2(handlerSpecificDeps))
mux.Handle("/route3", middleware(handleSomething3(handlerSpecificDeps))
mux.Handle("/route4", middleware(handleSomething4(handlerSpecificDeps))
```
