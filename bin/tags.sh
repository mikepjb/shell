#!/bin/sh

set +e

user_tags_dir="$HOME/.tags"
user_src_dir="$HOME/src"
update="false" # update source code before generating tags

mkdir -p $user_tags_dir $user_src_dir

main() {
    case "${1:-all}" in
        "go")
            setup_go
            ;;
        "java")
            setup_java
            ;;
        "clojure")
            setup_clojure
            setup_java
            ;;
        "pull")
            update="true"
            setup_go
            setup_java
            setup_clojure
            ;;
        "all"|"")
            setup_go
            setup_java
            setup_clojure
            ;;
        *)
            echo "Usage: $0 [go|java|clojure|all]"
            exit 1
            ;;
    esac
}

setup_go() {
    setup_language_tags "go" \
        "https://github.com/golang/go.git" "Go" "go.tags"
}

setup_java() {
    setup_language_tags "java" \
        "https://github.com/corretto/corretto-17.git" "Java" "java.tags"
}

setup_clojure() {
    setup_language_tags "clojure" \
        "https://github.com/clojure/clojure.git" "Clojure,Java" "clojure.tags"
}

setup_language_tags() {
    local name="$1"
    local git_url="$2"
    local ctags_languages="$3"
    local tag_file="$4"
    
    if command -v "$name" >/dev/null 2>&1; then
        echo "generating tags for $name"
        local src_dir="$user_src_dir/$name"
        
        if [[ ! -d "$src_dir" ]]; then
            git clone --depth 1 "$git_url" "$src_dir"
        else
            if [[ "$update" = "true" ]]; then
                (cd "$src_dir" && git pull origin master)
            fi
        fi
        
        ctags --languages="$ctags_languages" -f "$user_tags_dir/$tag_file" -R "$src_dir"
    fi
}

# if missing, get java/clojure/node/go

# generate langauge tags in .vim folder

# -- Generate 3rd party/dep sources ----

# from places like.. .m2 for clojure, go has it's GOROOT I think?, node has
# node_modules locally and java has gradle area?

# we end up with tags per language again but for the user-level caches e.g .m2
# folder has ALL deps we use across all projects that I have downloaded

# -- Finally generate tags based on your code

# -- Result.. tags that can be applied for any of the languages I work with.

main "$@"
