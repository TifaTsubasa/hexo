tableView在编辑模式下，提供了非常优秀的系统特性，无论是删除、添加还是移动都有着很棒的效果，比如移动效果

![](http://www.gamecd.com.cn/blog/images/blogImages/02-01.jpg)

基于MVC的设计理念，在对tableView这样的视图层进行更改时，应该先对模型层进行更改，因此应当首先改变tableView的 dataSource数组

在对tableView进行移动操作时，结合可变数组提供的方法，很容易使用下面的方法

    - (void)tableView:(UITableView *)tableView
    moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath
    toIndexPath:(NSIndexPath *)destinationIndexPath
    {
        [self.array exchangeObjectAtIndex:sourceIndexPath.row
    withObjectAtIndex:destinationIndexPath.row];
    }

代理方法提供了一个原始位置和目标位置，看似用一个exchange就可以搞定， 但实际上移动的那个cell并不是交换了位置，而是移动了位置，因此应当先移除原始位置的模型， 再插入到目标位置，正确的做法是：


    - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
    {
        id obj = self.array[sourceIndexPath.row];

        [self.array removeObject:obj];
        [self.array insertObject:obj atIndex:destinationIndexPath.row];
    }