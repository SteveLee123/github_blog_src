<template>
  <div class="page-search">
    <div class="search flex flex-middle">
      <i class="iconfont icon-search"></i>
      <input
        class="flex-item"
        type="text"
        placeholder="search"
        v-model="search"
        @input="handleInput"
      />
    </div>

    <div class="tips" v-if="archives.totalCount">
      <p>共 {{ archives.totalCount }} 条搜索结果</p>
    </div>

    <ul class="archives">
      <li
        class="archive"
        v-for="archive in archives.list"
        :key="archive.number"
      >
        <div class="archive-header flex flex-middle">
          <span class="date" v-text="formatTime(archive.createdAt, 'yyyy-MM-dd')"></span>
          <router-link
            :to="`/archives/${archive.number}`"
            :title="archive.title"
          >
            {{ archive.title }}
          </router-link>
        </div>
        <p>{{ archive.bodyText }}</p>
      </li>
    </ul>

    <div
      class="auxi flex flex-middle flex-center"
      v-if="archives.none"
    >
      <i class="iconfont icon-none"></i>
      <span>目前就这么多啦~</span>
    </div>

    <div
      class="auxi flex flex-middle flex-center"
      v-else-if="archives.loading"
    >
      <i class="iconfont icon-loading"></i>
      <span>正在加载中</span>
    </div>

    <div
      class="flex flex-middle flex-center"
      v-else-if="archives.totalCount"
    >
      <a
        class="btn-next flex flex-middle flex-center"
        href="javascript:;"
        @click="getData"
      >
        加载更多
      </a>
    </div>
  </div>
</template>

<script>
import { debounce } from '../utils/utils';
import { formatTime, getZodiac } from '../utils/utils';

export default {
  name: 'Search',

  data() {
    return {
      search: '',
      archives: {
        list: [],
        totalCount: 0,
        cursor: null,
        loading: false,
        none: false,
      },
    };
  },
  created() {
    // ✅ 在生命周期里创建 debounce，只创建一次
    this.onInputDebounced = debounce(this.onInput, 300);
  },

  methods: {
    formatTime,
    handleInput() {
      // Vue 事件层，不直接 debounce
      this.onInputDebounced();
    },

    onInput() {
      this.resetData();
      if (this.search && !this.archives.loading) {
        this.getData();
      }
    },

    resetData() {
      this.archives.cursor = null;
      this.archives.loading = false;
      this.archives.none = false;
      this.archives.list = [];
      this.archives.totalCount = 0;
    },

    getData() {
      this.archives.loading = true;

      const query = `query {
        search(
          query: "${this.search} repo:Young-LAO/github_blog_src",
          type: ISSUE,
          first: 10,
          after: ${this.archives.cursor}
        ) {
          issueCount
          pageInfo {
            endCursor
            hasNextPage
          }
          nodes {
            ... on Issue {
              createdAt,
              title
              bodyText
              number
            }
          }
        }
      }`;
      console.log(query);


      this.$http(query).then((res) => {
        const { nodes, pageInfo, issueCount } = res.search;
        console.log(res.search);

        this.archives.loading = false;
        this.archives.list = this.archives.list.concat(nodes);
        this.archives.totalCount = issueCount;
        this.archives.cursor = pageInfo.endCursor
          ? `"${pageInfo.endCursor}"`
          : null;

        if (!pageInfo.hasNextPage) {
          this.archives.none = true;
        }

        document.title = `${this.search} - 搜索 - LAO Blog`;
      });
    },
  },
};
</script>
<style lang="scss" scoped>
  .pc-mode {
    .page-search {
      .search {
        margin-left: 20px;

        &:before {
          content: '';
          position: absolute;
          left: -22px;
          top: 50%;
          margin-top: -4px;
          width: 8px;
          height: 8px;
          border-radius: 50%;
          background-color: #dddddd;
        }
      }

      .archives {
        padding-left: 20px;

        .archive a {
          &:before {
            content: '';
            position: absolute;
            left: -22px;
            top: 50%;
            margin-top: -4px;
            width: 8px;
            height: 8px;
            border-radius: 50%;
            background-color: #dddddd;
          }
        }
      }
    }
  }

  .page-search {
    .search {
      position: relative;
      max-width: 400px;
      background-color: #f0f0f0;
      height: 36px;
      border-radius: 18px;
      padding: 0 16px;

      i {
        font-size: $sizeMedium;
        margin-left: -8px;
        margin-right: 8px;
      }

      input {
        position: relative;
        height: 100%;
        background-color: transparent;
        border: none;
        font-size: $sizeMedium;
        color: $mainStrong;
      }
    }

    .archives {
      margin-top: 32px;
      margin-bottom: 16px;
      list-style: none;
      .archive {
        position: relative;
        line-height: 1.5;
        .archive-header {
          display: flex;
          align-items: baseline; // 或者是 center，取决于你想要文字对齐基准线还是中心
          margin-bottom: 8px;    // 与下方描述文字的间距

          .date {
            font-size: $sizeSmall;
            color: #888888;
            white-space: nowrap;
            margin-right: 12px; // 增加与标题的间距
            flex-shrink: 0;     // 防止日期被压缩
          }

          a {
            // 移除 display: block; 
            display: inline-block; 
            font-size: $sizeMedium;
            font-weight: bold;
            color: $mainStrong;
            text-overflow: ellipsis;
            white-space: nowrap;
            overflow: hidden;
            transition: all 0.5s;

            &:hover, &:active {
              color: #1abc9c;
            }
          }
        }
        p {
          color: #555555;
          font-size: $sizeNormal;
          line-height: 1.5;
          max-height: 96px;
          margin-top: 8px;
          display: -webkit-box;
          -webkit-box-orient: vertical;
          -webkit-line-clamp: 4;
          overflow: hidden;
          word-break: break-all;
        }
      }

      .archive + .archive {
        margin-top: 32px;
      }
    }

    .tips {
      position: relative;
      margin-left: 20px;
      margin-top: 16px;

      p {
        font-size: $sizeNormal;
        color: #999999;
      }
    }
  }
</style>
